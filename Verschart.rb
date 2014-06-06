## Ver 2.1
require 'chef/knife'
require 'chef/search/query'

module Verschart
  class Verschart < Chef::Knife
    banner 'knife verschart'

    def run
	red = 31
	teal = 36

	# set environment list
	#### Need to add variability - pull from envs.search (uncomment line 20).
	#### --  Then how do I sort to my preference?
	#### --  How do I designate a "PROD" which must be frozen?
	primary = 'PRODUCTION'
	srv = server_url.sub(%r{https://}, '').sub(/:[0-9]*$/, '')
	ui.info("Showing Versions for #{srv}")
	ui.info('')
	ui.info("Version numbers in the Latest column in \e[#{teal}mteal\e[0m are frozen")
	ui.info("Version numbers in the #{primary} Environment which are NOT frozen will be \e[#{red}mred\e[0m.")
	ui.info('')
	hdrs = %w(Cookbooks Latest Sandbox Dev Dev2 IT Staging PRODUCTION)

	# Build environment hash containing all constraints.
	search_envs = Chef::Search::Query.new
	qury = 'NOT name:_default'

	charthash = {}
	search_envs.search('environment', qury) do |enviro|
	# hdrs << enviro.name
	  charthash[enviro.name] = Hash.new
	  if enviro.name.length > 8
	    charthash[enviro.name]['col'] = enviro.name.length + 2
	  else
	    charthash[enviro.name]['col'] = 10
	  end
	  enviro.cookbook_versions.each do | cb, v|
	    charthash[enviro.name][cb] = Hash.new(0)
	    charthash[enviro.name][cb]['vs'] = v.to_s
	    if enviro.name == primary
	      fm = Chef::CookbookVersion.load(cb, version = "#{v.to_s.sub(/[<=> ]*/, '')}")
 	      charthash[enviro.name][cb]['color'] = red if !fm.frozen_version?
	    end
	  end
	end

	# Set printf format string.  Add variability later (perhaps above when creating hdrs array.
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
	   unless charthash[hdr].key?(fm.metadata.name)
	     charthash[hdr][fm.metadata.name] = Hash.new(0)
	     charthash[hdr][fm.metadata.name]['vs'] = 'X'
	   end
	  end
	end

	charthash['Cookbooks']['col'] = cblen + 2

	hdrs.each do | hdr |
	  printf("%-#{charthash[hdr]['col']}s", hdr)
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
    end
  end
end
