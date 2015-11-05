## Ver 2.7.3
require 'chef/knife'
require 'chef/search/query'

class String
  def red
    "\033[31m\033[1m#{self}\033[0m"
  end

  def purple
    "\033[35m#{self}\033[0m"
  end

  def teal
    "\033[36m#{self}\033[0m"
  end

  # Bold & blue back-ground
  def bold
    "\033[44m\033[1m#{self}\033[0m"
  end

  def yellow
    "\033[30m\033[43m#{self}\033[0m"
  end
end

module Verschart
  class Verschart < Chef::Knife
    banner 'knife verschart [--primary env[,env,...]] [[-o| --env_order] env[,env,...]] [[--cbselect] cookbook[,cookbook,...]]'

    option :primary,
           long: '--primary env[,env,...]',
           description: 'A comma-separated list of environments to be considered primary. Versions which are NOT frozen willl be highlighted red.',
           proc: proc { |primary| Chef::Config[:knife][:primary] = primary.split(',') }

    option :html,
           long: '--html',
           description: 'Output in basic html fomat.',
           proc: proc { |_html| Chef::Config[:knife][:html] = true }

    option :envorder,
           short: '-o env[,env,....]',
           long: '--env_order env[,env,....]',
           description: 'A comma-separated list of environments to establish a display order. Any existing environments not included in this list will be added at the end',
           proc: proc { |envorder| Chef::Config[:knife][:envorder] = envorder.split(',') }

    option :cbselect,
           long: '--cbselect cookbook[,cookbook,....]',
           description: 'A comma-separated list of cookbooks to include in the chart',
           proc: proc { |cbselect|  Chef::Config[:knife][:cbselect] = cbselect.split(',') }

    def run
      # Load Options
      primary = config[:primary] || []
      order = config[:envorder] || []
      envorder = []
      unless order.empty?
        if order.is_a?(String)
          envorder = order.split(',')
        elsif order.is_a?(Array)
          order.each { |env| envorder << env }
        end
      end
      srv = server_url.sub(%r{https://}, '').sub(/:[0-9]*$/, '')
      cbselect = config[:cbselect] || []
      html = config[:html] || false

      # Opening output
      if html
        ui.info('<!DOCTYPE html>')
        ui.info('<html>')
        ui.info('<body>')
        ui.info("<p>Showing Versions for #{srv}")
        ui.info('</BR>')
        ui.info("Version numbers in the Latest column in <span style='color:blue'> blue</span> are frozen</BR>")
        ui.info("Version numbers in the <span style='color:purple'><strong><u>primary</u></strong></span> Environment(s) which are NOT frozen will be <span style='background:yellow;color:red'>red</span></BR>")
        ui.info("Version numbers which do not exist on the server will be in <span style='background:green;color:white'>green</span> highlight</BR>")
        ui.info("Version numbers which are different from the Latest (but do exist), will be in <span style='background:blue;color:white'>blue</span> highlight</BR>")
        ui.info("Requested environment order is #{envorder}</BR>") unless envorder.empty?
        ui.info('No Requested environment order</BR>') if envorder.empty?
        ui.info('')
      else
        ui.info("Showing Versions for #{srv}")
        ui.info('')
        ui.info('Version numbers in the Latest column in ' + 'teal'.teal + ' are frozen')
        ui.info('Version numbers in the ' + 'primary'.purple + ' Environment(s) which are NOT frozen will be ' + 'red'.red) unless primary.empty?
        ui.info('Version numbers which do not exist on the server will be in ' + 'yellow'.yellow)
        ui.info('Version numbers which are different from the Latest (but do exist), will be in ' + 'blue'.bold)
        ui.info("Requested environment order is #{envorder}") unless envorder.empty?
        ui.info('No Requested environment order') if envorder.empty?
        ui.info('')
      end

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
      hdrs = %w(Cookbooks Latest).concat(envs)

      # counter for longest cookbook name
      cblen = 10

      charthash = {}  # The hash for all chart data
      # store list of availible cookbook versions for comparison to constraint
      vers_store = Chef::CookbookVersion.list_all_versions

      # Load list of latest cookbook versions
      charthash['Latest'] = {}
      charthash['Cookbooks'] = {}
      charthash['Latest']['col'] = 12
      r = Regexp.union(cbselect)
      server_side_cookbooks = Chef::CookbookVersion.list
      server_side_cookbooks.each do |svcb|
        select_match = false
        select_match = true if !cbselect.empty? && r =~ svcb[0]
        if cbselect.empty? || select_match
          fm = Chef::CookbookVersion.load(svcb[0])
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
      end

      # Set first column width
      charthash['Cookbooks']['col'] = cblen + 2

      # Load vers constraints
      search_envs.search('environment', qury) do |enviro|
        charthash[enviro.name] = {}
        if enviro.name.length > 8
          charthash[enviro.name]['col'] = enviro.name.length + 2
        else
          charthash[enviro.name]['col'] = 10
        end
        enviro.cookbook_versions.each do |cb, v|
          if charthash['Latest'].key?(cb)
            charthash[enviro.name][cb] = Hash.new(0)
            charthash[enviro.name][cb]['vs'] = v.to_s
            vn = v.to_s.split(' ')[1]
            charthash[enviro.name][cb]['red'] = false
            charthash[enviro.name][cb]['teal'] = false
            charthash[enviro.name][cb]['yellow'] = true
            charthash[enviro.name][cb]['bold'] = false
            vers_store[cb]['versions'].each do |vss|
              if vss['version'] == vn
                charthash[enviro.name][cb]['yellow'] = false
              end
            end
            if !primary.empty? && primary.include?(enviro.name) && !charthash[enviro.name][cb]['yellow']
              fm = Chef::CookbookVersion.load(cb, version = "#{vn}")
              charthash[enviro.name][cb]['red'] = true unless fm.frozen_version?
            end
            if vn != charthash['Latest'][cb]['vs'] && !charthash[enviro.name][cb]['yellow']
              charthash[enviro.name][cb]['bold'] = true
            end
          end
        end
      end

      if html
        ### html format here!
        print "<table border='1' style='width:75%;border-collapse:collapse;font-size:14px'>"
        print('</tr>')
        print('<tr>')
        hdrs.each do |hdr|
          if !primary.empty? && primary.include?(hdr)
            print "<td style='color:purple'><strong><u>#{hdr.ljust(charthash[hdr]['col'])}</u></strong></td>\n"
          else
            print "<td><strong>#{hdr.ljust(charthash[hdr]['col'])}</strong></td>\n"
          end
        end
        print("</tr>\n")

        # Print the Chart data
        charthash['Cookbooks'].keys.sort.each do |cbk|
          print('<tr>')
          unless cbk == 'col'
            hdrs.each do |hdr|
              case hdr
              when 'Cookbooks'
                print "<td>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</td>\n"
              when 'Latest'
                if charthash[hdr][cbk]['teal']
                  print "<td style='color:blue'>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</td>\n"
                else
                  print "<td>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</td>\n"
                end
              else
                if charthash[hdr].key?(cbk)
                  if charthash[hdr][cbk]['bold']
                    if charthash[hdr][cbk]['red']
                      print "<td style='background:yellow;color:red'><strong>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</strong></td>\n"
                    elsif charthash[hdr][cbk]['yellow']
                      print "<td style='background:blue;color:green'><strong>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</strong></td>\n"
                    else
                      print "<td style='background:blue;color:white'><strong>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</strong></td>\n"
                    end
                  else
                    if charthash[hdr][cbk]['red']
                      print "<td style='background:yellow;color:red'><strong>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</strong></td>\n"
                    elsif charthash[hdr][cbk]['yellow']
                      print "<td style='color:white;background:green'>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</td>\n"
                    else
                      print "<td>#{charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])}</td>\n"
                    end
                  end
                else
                  print '<td>X</td>'.ljust(charthash[hdr]['col'])
                end
              end
            end
            printf "</tr>\n"
          end
        end
        print "</table>\n"
        print "</body>\n"
        print "</html>\n"
      else
        ####  Old print format
        # Print the Chart headers
        hdrs.each do |hdr|
          if !primary.empty? && primary.include?(hdr)
            print hdr.purple.ljust(charthash[hdr]['col'])
          else
            print hdr.ljust(charthash[hdr]['col'])
          end
        end
        print "\n"

        # Print the Chart data
        charthash['Cookbooks'].keys.sort.each do |cbk|
          unless cbk == 'col'
            hdrs.each do |hdr|
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
                if charthash[hdr].key?(cbk)
                  if charthash[hdr][cbk]['bold']
                    if charthash[hdr][cbk]['red']
                      print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).red.bold
                    elsif charthash[hdr][cbk]['yellow']
                      print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).yellow.bold
                    else
                      print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).bold
                    end
                  else
                    if charthash[hdr][cbk]['red']
                      print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).red
                    elsif charthash[hdr][cbk]['yellow']
                      print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col']).yellow
                    else
                      print charthash[hdr][cbk]['vs'].ljust(charthash[hdr]['col'])
                    end
                  end
                else
                  print 'X'.ljust(charthash[hdr]['col'])
                end
              end
            end
            printf "\n"
          end
        end

        if cbselect.empty?
          # Look for obsolete constraints
          hd = 0 # Flag for section header
          ev = 0 # Flag for Environent header

          envs.each  do |env|
            charthash[env].keys.each do |ckbk|
              unless charthash['Cookbooks'].key?(ckbk)
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
  end
end
