knife-verschart
===============

Plug-in for Chef's knife to print a chart of all cookbooks and the version constraints contained in each environment.
Any obsolete version constraints (i.e. constraints for cookbooks which do not exist on the server) are also listed.


Installation and Config
============
gem install knife-verschart

Alternate install method:
-------------------------
Place the Verschart.rb file in your knife plugins directory. 

ex. `cp lib/chef/knife/Verschart.rb ~/.chef/plugins/knife/Verschart.rb`


Config
------
One or more 'primary' environments can be set either on the command line or in knife.rb. These environments will show in red for any versions which are NOT frozen.  

The list of environments is pulled from the Chef server (_default is ignored).  A prefered display order can be specified either on the command line or in knife.rb.


USE
===

Command line:
-------------

```sh
knife verschart [--primary environment[,environment,...]]
    --primary environment[,environment,...] A comma-separated list of environments to be considered primary. Versions which are NOT frozen willl be highlighted red.
    -o, --env_order env[,env,....]   A comma-separated list of environments to establish an display order. Any existing environments not included in this list will be added at the end
    --cbselect cookbook[,cookbook,....]   A comma-separated list of cookbooks to list.  Each entry in the list is treated as a regex when comparing the cookbook name.
```

knife.rb:
---------
```sh
knife[:primary] = "PRODUCTION"  - Sets the primary environment(s)
knife[:envorder] = "Sandbox,Dev,Dev2,IT,Staging,PRODUCTION" - Sets the environment display order.
```

Output will look something like this:

```sh
Showing Versions for chef01.example.com

Version numbers in the Latest column in teal are frozen
Version numbers in the PRODUCTION Environment(s) which are NOT frozen will be red.
Version numbers which are different from the Latest, will be in blue
Requested Environment order is ["Sandbox", "Dev", "Dev2", "IT", "Staging", "PRODUCTION"]


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

Obsolete Version constraints are listed below

Sandbox
-- apache   <= 3.2.1
```

TO-DO
=====
1. Denote (perhaps with color) that a particular verison does not exist.
2. Denote (perhaps with color) constraints where no cookbook version exists to match the constraint.
3. Bombs, if version of constraint doesn't exist on server  (can't re-create now)
4. Ability to limit cookbooks some how
   a. Useing list
   b. Using re

