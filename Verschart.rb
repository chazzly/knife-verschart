## Ver 1.1
require 'chef/knife'
require 'chef/search/query'

module Verschart
  class Verschart < Chef::Knife
    banner 'knife verschart'

    def run
 
	# set environment list
	#### Need to add variability - pull from envs.search (uncomment line 20).
	#### --  Then how do I sort to my preference?
	#### --  How do I designate a "PROD" which must be frozen?
	srv = server_url.sub(/https:\/\//,'').sub(/:[0-9]*$/,'')
	ui.info("Showing Versions for #{srv}")
	ui.info("Version numbers show with '-f' are Frozen")
	ui.info("")
	hdrs= [ "Latest", "Sandbox", "Dev", "IT", "Staging", "PRODUCTION" ]

	# Build environment hash containing all constraints.
	search_envs = Chef::Search::Query.new
	qury = "NOT name:_default"

	charthash = Hash.new
	search_envs.search('environment', qury ) do |enviro|
	# hdrs << enviro.name
	  charthash[enviro.name] = Hash.new("X")
	  enviro.cookbook_versions.each do | cb, v|
	    charthash[enviro.name][cb] = v.to_s
	    if enviro.name == "PRODUCTION"
	      fm = Chef::CookbookVersion.load(cb, version="#{v.to_s.sub(/[<=> ]*/,'')}")
	      charthash[enviro.name][cb] = charthash[enviro.name][cb] + " -f" if fm.frozen_version?
	    end
	  end
	end 	

	#Set printf format string.  Add variability later (perhaps above when creating hdrs array.
	cblen = 10

	# Load list of latest cookbooks
	charthash['Latest'] = Hash.new
	server_side_cookbooks = Chef::CookbookVersion.latest_cookbooks
	server_side_cookbooks.each do |svcb|
	  mykb_name = svcb[0]
	  fm = Chef::CookbookVersion.load(mykb_name, version="_latest")
	  cblen = mykb_name.length if mykb_name.length > cblen
	  charthash['Latest'][fm.metadata.name] = fm.metadata.version.to_s
	  charthash['Latest'][fm.metadata.name] = charthash['Latest'][fm.metadata.name] + " -f" if fm.frozen_version?
	end
	
	pstring = "%-#{cblen + 2}s%-12s"
	hdrs.each do | env |
	  unless env == 'Latest' 
	    if env.length > 8 
	      sz = env.length + 2
	    else
	      sz = 10
	    end
	    pstring = pstring + "%-#{sz}s"
	  end
	end
	pstring = pstring + "\n"

	printf(pstring,"Cookbook", *hdrs)
	charthash['Latest'].keys.each do |cb|
	  cbout = [cb]
	  hdrs.each do | env | 
	    cbout << charthash[env][cb]
	  end
	  printf(pstring, *cbout)
	end
    end
  end
end
