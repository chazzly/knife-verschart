## Ver 2.3
require 'chef/knife'
require 'chef/search/query'

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
	red = 31
	purple = 35
	teal = 36

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
	ui.info("Version numbers in the Latest column in \e[#{teal}mteal\e[0m are frozen")
	ui.info("Version numbers in the \e[#{purple}m#{primary}\e[0m Environment(s) which are NOT frozen will be \e[#{red}mred\e[0m.") unless primary.empty?
	ui.info("Requested order is #{envorder}") unless envorder.empty?
	ui.info('')

	# Build environment list and hash containing all constraints.
	envis = []  # Placeholder for found environments
	search_envs = Chef::Search::Query.new
	qury = 'NOT name:_default'

	charthash = Hash.new  # The hash for all chart data
	search_envs.search('environment', qury) do |enviro|
	  envis << enviro.name 
	  charthash[enviro.name] = Hash.new
	  if enviro.name.length > 8
	    charthash[enviro.name]['col'] = enviro.name.length + 2
	  else
	    charthash[enviro.name]['col'] = 10
	  end
	  enviro.cookbook_versions.each do | cb, v|
	    charthash[enviro.name][cb] = Hash.new(0)
	    charthash[enviro.name][cb]['vs'] = v.to_s
	    if !primary.empty? && primary.include?(enviro.name)
	      fm = Chef::CookbookVersion.load(cb, version = "#{v.to_s.sub(/[<=> ]*/, '')}")
 	      charthash[enviro.name][cb]['color'] = red unless fm.frozen_version?
	    end
	  end
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

	# Load list of latest cookbook versions
	charthash['Latest'] = {}
	charthash['Cookbooks'] = {}
	charthash['Latest']['col'] = 12
	server_side_cookbooks = Chef::CookbookVersion.latest_cookbooks
	server_side_cookbooks.each do |svcb|
	  fm = Chef::CookbookVersion.load(svcb[0], version = '_latest')
	  cblen = fm.metadata.name.length if fm.metadata.name.length > cblen
	  charthash['Latest'][fm.metadata.name] = Hash.new(0)
	  charthash['Cookbooks'][fm.metadata.name] = Hash.new(0)
	  charthash['Latest'][fm.metadata.name]['vs'] = fm.metadata.version.to_s
	  charthash['Cookbooks'][fm.metadata.name]['vs'] = fm.metadata.name
	  charthash['Latest'][fm.metadata.name]['color'] = teal if fm.frozen_version?
	  hdrs.each do |hdr|
	    unless charthash[hdr].has_key?(fm.metadata.name)
	      charthash[hdr][fm.metadata.name] = Hash.new(0)
	      charthash[hdr][fm.metadata.name]['vs'] = 'X'
	    end
	  end
	end

	# Set first column width
	charthash['Cookbooks']['col'] = cblen + 2

	# Print the Chart headers
	hdrs.each do | hdr |
	  if !primary.empty? && primary.include?(hdr) 
	    printf("\e[#{purple}m%-#{charthash[hdr]['col']}s\e[0m", hdr)
	  else
	    printf("%-#{charthash[hdr]['col']}s", hdr)
	  end
	end
	printf "\n"

	# Print the Chart data
	charthash['Cookbooks'].keys.each do | cbk |
	  unless cbk == 'col'
	    hdrs.each do | hdr |
	      printf("\e[#{charthash[hdr][cbk]['color']}m%-#{charthash[hdr]['col']}s\e[0m", charthash[hdr][cbk]['vs'])
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
