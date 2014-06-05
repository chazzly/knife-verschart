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
	hdrs= [ "Latest", "Sandbox", "Dev", "IT", "Staging", "PRODUCTION" ]

	# Build environment hash containing all constraints.
	search_envs = Chef::Search::Query.new
	qury = "NOT name:_default"

	charthash = Hash.new
	search_envs.search('environment', qury ) do |enviro|
#	  hdrs << enviro.name
	  charthash[enviro.name] = Hash.new("X")
	  enviro.cookbook_versions.each do | cb, v|
	    charthash[enviro.name][cb] = v.to_s
	    if enviro.name == "PRODUCTION"
	      fm = Chef::CookbookVersion.load(cb, version="#{v.to_s.sub(/[<=> ]*/,'')}")
	      charthash[enviro.name][cb] = charthash[enviro.name][cb] + " -f" if fm.frozen_version?
	    end
	  end
	end 	

	charthash['Latest'] = Hash.new
	# Load list of latest cookbooks
	server_side_cookbooks = Chef::CookbookVersion.latest_cookbooks
	server_side_cookbooks.each do |svcb|
	  mykb_name= svcb[0]
	  fm = Chef::CookbookVersion.load(mykb_name, version="_latest")
#	  ui.info("#{fm.metadata.name} -- #{fm.metadata.version}")
	  charthash['Latest'][fm.metadata.name] = fm.metadata.version.to_s
	  charthash['Latest'][fm.metadata.name] = charthash['Latest'][fm.metadata.name] + " -f" if fm.frozen_version?
	end

#	charthash.keys.each do | mynv |
#	  ui.info("#{mynv}")
#	end
	
#	hdrs.each do | myenv |
#	  ui.info("#{myenv.class}")
#	  ui.info("#{myenv}")
#	  charthash[myenv].keys.each do | cbks |
#	    vs = charthash[myenv][cbks]
#	    ui.info("#{myenv} .. #{cbks} .. #{vs}")
#	  end
#	end
	
	#Set printf format string.  Add variability later (perhaps above when creating hdrs array.
	pstring = "%-35s%-12s%-10s%-10s%-10s%-10s%-10s\n"
	printf(pstring,"Cookbooks", *hdrs)
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
