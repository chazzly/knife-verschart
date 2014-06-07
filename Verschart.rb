## Ver 2.2
require 'chef/knife'
require 'chef/search/query'

module Verschart
  class Verschart < Chef::Knife
    banner 'knife verschart [-e environment[,environment,...]]'

    option :primary,
      :short => "-e environment[,environment,...]",
      :description => "A comma-separated list of environments to be considered primary. Versions which are NOT frozen willl be highlighted red.",
      :proc => Proc.new { |primary| Chef::Config[:knife][:primary] = primary.split(',') }

    def run
	red = 31
	blue = 34
	purple = 35
	teal = 36

	# set environment list
	#### Need to add variability - pull from envs.search (uncomment line 20).
	#### --  Then how do I sort to my preference?
	#### --  How do I designate a "PROD" which must be frozen?
	primary = config[:primary] || []
	srv = server_url.sub(%r{https://}, '').sub(/:[0-9]*$/, '')
	ui.info('')
	ui.info("Showing Versions for #{srv}")
	ui.info('')
	ui.info("Version numbers in the Latest column in \e[#{teal}mteal\e[0m are frozen")
	ui.info("Version numbers in the \e[#{blue}m#{primary}\e[0m Environment(s) which are NOT frozen will be \e[#{red}mred\e[0m.") unless primary.empty?
	ui.info('')
	envs = %w(Sandbox Dev Dev2 IT Staging PRODUCTION)

	# Build environment hash containing all constraints.
	search_envs = Chef::Search::Query.new
	qury = 'NOT name:_default'

	charthash = {}
	search_envs.search('environment', qury) do |enviro|
	# envs << enviro.name
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

	hdrs = ['Cookbooks', 'Latest'].concat(envs)

	# counter for longest cookbook name
	cblen = 10

	# Load list of latest cookbooks
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

	charthash['Cookbooks']['col'] = cblen + 2

	hdrs.each do | hdr |
	  if !primary.empty? && primary.include?(hdr) 
	    printf("\e[#{blue}m%-#{charthash[hdr]['col']}s\e[0m", hdr)
	  else
	    printf("%-#{charthash[hdr]['col']}s", hdr)
	  end
	end
	printf "\n"

	charthash['Cookbooks'].keys.each do | cbk |
	  unless cbk == 'col'
	    hdrs.each do | hdr |
	      printf("\e[#{charthash[hdr][cbk]['color']}m%-#{charthash[hdr]['col']}s\e[0m", charthash[hdr][cbk]['vs'])
	    end
	  end
	  printf "\n"
	end

	### Look for obsolete constraints
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
