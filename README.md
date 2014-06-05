knife-verschart
===============

Plug-in for Chef's knife to print a chart of all cookbooks and the version constraints contained in each environment.`


Installation
============
Place the Verschart.rb file in your knife plugins directory. 

ex.
`cp Verschart.rb ~/.chef/plugins/knife/Verschart.rb`

USE
===
`knife verschart` (no argumnets)

Output will look something like this:

Cookbooks                          Latest      Sandbox   Dev       IT        Staging   PRODUCTION
cron                               1.2.8 -f    <= 1.2.8  <= 1.2.8  <= 1.2.8  <= 1.2.8  <= 1.2.8 -f
hostsfile                          2.4.4       <= 2.4.4  <= 2.4.4  <= 2.4.4  <= 2.4.4  <= 2.4.4
line                               0.5.1 -f    <= 0.5.1  <= 0.5.1  <= 0.5.1  <= 0.5.1  <= 0.5.1 -f
log_rotations                      0.0.1 -f    <= 0.0.1  <= 0.0.1  X  	     X	       X
logrotate                          1.4.0 -f    <= 1.4.0  <= 1.4.0  <= 1.4.0  <= 1.4.0  <= 1.4.0 -f
netgroup                           0.1.0 -f    <= 0.1.0  <= 0.1.0  <= 0.1.0  <= 0.1.0  <= 0.1.0 -f
ohai                               1.1.12 -f   <= 1.1.12 <= 1.1.12 <= 1.1.12 <= 1.1.12 <= 1.1.12 -f
ssh                                0.6.5 -f    <= 0.6.5  <= 0.6.5  <= 0.6.5  <= 0.6.5  <= 0.6.5 -f
ssh-keys                           1.0.0 -f    <= 1.0.0  <= 1.0.0  <= 1.0.0  <= 1.0.0  <= 1.0.0 -f
yum                                3.1.4 -f    <= 3.1.4  <= 3.1.4  <= 3.1.4  <= 3.1.4  <= 3.1.4 -f


TO-DO
=====
1. List of Environments is currently hardcoded. Can pull from chef server easily, but need a way to estabilish sort order.
2. Need a way to designate which env, if any, should list if that version is frozen or not.
3. Denote (perhaps with color) that a particular verison does not exist.
3a. Denote constraints where no cookbook version exists to match the constraint.
4. Show obsolete constraints (constraints for cookbook that do not exist at all)
