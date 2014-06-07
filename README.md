knife-verschart
===============

Plug-in for Chef's knife to print a chart of all cookbooks and the version constraints contained in each environment.`


Installation
============
Place the Verschart.rb file in your knife plugins directory. 

ex.
`cp Verschart.rb ~/.chef/plugins/knife/Verschart.rb`

One or more 'primary' environments can be set. These environments will highlight in red any versions which are NOT frozen.  

USE
===
`knife verschart` (no argumnets)

Output will look something like this:

Showing Versions for cs1chl001.classifiedventures.com

Version numbers in the Latest column in teal are frozen
Version numbers in the <primary> Environment(s) which are NOT frozen will be red.


Cookbooks                          Latest      Sandbox   Dev       IT        Staging   PRODUCTION
cron                               1.2.8       <= 1.2.8  <= 1.2.8  <= 1.2.8  <= 1.2.8  <= 1.2.8 
hostsfile                          2.4.4       <= 2.4.4  <= 2.4.4  <= 2.4.4  <= 2.4.4  <= 2.4.4
line                               0.5.1       <= 0.5.1  <= 0.5.1  <= 0.5.1  <= 0.5.1  <= 0.5.1 
log_rotations                      0.0.1       <= 0.0.1  <= 0.0.1  X  	     X	       X
logrotate                          1.4.0       <= 1.4.0  <= 1.4.0  <= 1.4.0  <= 1.4.0  <= 1.4.0 
netgroup                           0.1.0       <= 0.1.0  <= 0.1.0  <= 0.1.0  <= 0.1.0  <= 0.1.0 
ohai                               1.1.12      <= 1.1.12 <= 1.1.12 <= 1.1.12 <= 1.1.12 <= 1.1.12 
ssh                                0.6.5       <= 0.6.5  <= 0.6.5  <= 0.6.5  <= 0.6.5  <= 0.6.5 
ssh-keys                           1.0.0       <= 1.0.0  <= 1.0.0  <= 1.0.0  <= 1.0.0  <= 1.0.0 
yum                                3.1.4       <= 3.1.4  <= 3.1.4  <= 3.1.4  <= 3.1.4  <= 3.1.4 


TO-DO
=====
1. List of Environments is currently hardcoded. Can pull from chef server easily, but need a way to estabilish sort order.
2. Enable primary Environment to be set via commandline or knife.rb
3. Denote (perhaps with color) that a particular verison does not exist.
3a. Denote (perhaps with color) constraints where no cookbook version exists to match the constraint.
