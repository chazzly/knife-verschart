## Ver 2.5
require 'chef/knife'
require 'chef/search/query'

class String
  def red;            "\033[31m#{self}\033[0m" end
  def purple;            "\033[35m#{self}\033[0m" end
  def teal;            "\033[36m#{self}\033[0m" end
  def bold;          "\033[44m\033[1m#{self}\033[0m" end # Bold & blue back-ground
end

module Verschart
  class Verschart < Chef::Knife
    banner 'knife verschart [-e env[,env,...]] [[-o| --env_order] env[,env,...]]'

    option :primary,
      :short => "-e env[,env,...]",
      :description => "A comma-separated list of environments to be considered primary. Versions which are NOT frozen willl be highlighted red.",
      :proc => Proc.new { |primary| Chef::Config[:knife][:primary] = primary.split(',') }

    option :envorder,
      :short => "-o env[,env,....]",
      :long => "--env_order env[,env,....]", 
      :description => "A comma-separated list of environments to establish an display order. Any existing environments not included in this list will be added at the end",
      :proc => Proc.new { |envorder| Chef::Config[:knife][:envorder] = envorder.split(',') }

    def run
	# Load Options
	primary = config[:primary] || []
	order = config[:envorder] || []
	envorder = []
	envorder = order.split(',') unless order.empty?
	srv = server_url.sub(%r{https://}, '').sub(/:[0-9]*$/, '')

	# Opening output
	ui.info('')
	ui.info("Showing Versions for #{srv}")
	ui.info('')
	ui.info("Version numbers in the Latest column in " + "teal".teal + " are frozen")
	ui.info("Version numbers in the " + "primary".purple + " Environment(s) which are NOT frozen will be " + "red".red ) unless primary.empty?
	ui.info("Version numbers which are different from the Latest, will be in " + "blue".bold)
	ui.info("Requested environment order is #{envorder}") unless envorder.empty?
	ui.info('')

	# Build environment list and hash containing all constraints.
	envis = []  # Placeholder for found environments
	search_envs = Chef::Search::Query.new
	qury = 'NOT name:_default'

	search_envs.search('environment', qury) do |enviro|
	  envis << enviro.name 
	end

	envs = [] # Final ordered list of Environments
	unless envorder.empty?
	  envorder.each do |env|
	    if !envis.include?(env) 
	      ui.warn "#{env} is not a valid environment!"
	    else
	      envs << env 
	    end
	  end
	end
	envis.each do |env|
	  envs << env unless envs.include?(env)
	end
	  
	#  List of Chart headers
	hdrs = ['Cookbooks', 'Latest'].concat(envs)

	# counter for longest cookbook name
	cblen = 10

	charthash = Hash.new  # The hash for all chart data

	# Load list of latest cookbook versions
	charthash['Latest'] = Hash.new
	charthash['Cookbooks'] = Hash.new
	charthash['Latest']['col'] = 12
	server_side_cookbooks = Chef::CookbookVersion.latest_cookbooks
	server_side_cookbooks.each do |svcb|
	  fm = Chef::CookbookVersion.load(svcb[0], version = '_latest')
	  cblen = fm.metadata.name.length if fm.metadata.name.length > cblen
	  charthash['Latest'][fm.metadata.name] = Hash.new(0)
	  charthash['Cookbooks'][fm.metadata.name] = Hash.new(0)
	  charthash['Latest'][fm.metadata.name]['vs'] = fm.metadata.version.to_s
	  charthash['Cookbooks'][fm.metadata.name]['vs'] = fm.metadata.name
	  if fm.frozen_version?
	    charthash['Latest'][fm.metadata.name]['teal'] = true
	  else
	    charthash['Latest'][fm.metadata.name]['teal'] = false
	  end
	  charthash['Latest'][fm.metadata.name]['bold'] = false
	  charthash['Latest'][fm.metadata.name]['red'] = false
	end

	# Set first column width
	charthash['Cookbooks']['col'] = cblen + 2

	# Load vers constraints
	search_envs.search('environment', qury) do |enviro|
	  charthash[enviro.name] = Hash.new
	  if enviro.name.length > 8
	    charthash[enviro.name]['col'] = enviro.name.length + 2
	  else
	    charthash[enviro.name]['col'] = 10
	  end
	  enviro.cookbook_versions.each do | cb, v|
	    charthash[enviro.name][cb] = Hash.new(0)
	    charthash[enviro.name][cb]['vs'] = v.to_s
	    vn = v.to_s.split(' ')[1]
 	    charthash[enviro.name][cb]['red'] = false
 	    charthash[enviro.name][cb]['teal'] = false
	    if charthash['Latest'].has_key?(cb)  
   	      if !primary.empty? && primary.include?(enviro.name)
	        fm = Chef::CookbookVersion.load(cb, version = "#{vn}")
 	        charthash[enviro.name][cb]['red'] = true unless fm.frozen_version?
	      end
 	      if vn != charthash['Latest'][cb]['vs']
	        charthash[enviro.name][cb]['bold'] = true
	      else
	        charthash[enviro.name][cb]['bold'] = false
	      end
	    end
	  end
	end

	# Print the Chart headers
	hdrs.each do | hdr |
	  if !primary.empty? && primary.include?(hdr) 
	    print hdr.purple.ljust(charthash[hdr]['col'])
	  else
	    print hdr.ljust(charthash[hdr]['col'])
	  end
	end
	print "\n"

	# Print the Chart data
	charthash['Cookbooks'].keys.each do | cbk |
	  unless cbk == 'col'
	    hdrs.each do | hdr |
	      case hdr
	        when 'Cookbooks'
	          print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])
	        when 'Latest'
	          if charthash[hdr][cbk]['teal']
	            print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).teal
	          else
	            print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])
	          end
 	        else
	          if charthash[hdr].has_key?(cbk)
		    if charthash[hdr][cbk]['bold'] 
	 	      if charthash[hdr][cbk]['red']
		        print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).red.bold
		      else
		        print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).bold
		      end
                    else
	 	      if charthash[hdr][cbk]['red']
		        print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).red
		      else
		        print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])
		      end
		    end
	          else
		    print "X".ljust(charthash[hdr]['col'])
	          end
		end
	      end
	    end
	  printf "\n"
	end

	# Look for obsolete constraints
	hd = 0 # Flag for section header
	ev = 0 # Flag for Environent header

	envs.each  do |env|
	  charthash[env].keys.each do |ckbk|
	    unless charthash['Cookbooks'].has_key?(ckbk)
	      unless hd == 1
	        ui.info('')
	        ui.info('Obsolete Version constraints are listed below')
	        hd = 1
	      end
	      unless ev == 1
	        ui.info('')
	        ui.info(env)
	      end
	      ui.info("-- #{ckbk}   #{charthash[env][ckbk]['vs']}")
	    end
	  end
	end
    end
  end
end
