1.0
-----
cruhl - initial code

1.1
-----
cruhl - Clean up and making column widths variable based on content.

2.0
-----
cruhl - Re-worked printf calculation to use colors rather than "-f" for frozen.
	Limited checking for frozen to "Latest" and the primary environmnet

2.1
-----
cruhl - Allow multiple primaries
	Show obsolete constraints

2.2
----
cruhl - Primary environment(s) can now by set by cli option or in knife.rb

2.3
----
cruhl - Environments are now pulled from Chef server, Order can be set by cli option or in knife.rb
	Improved Comments & cleaned up a little.

2.4
----
cruhl - Added Highlight (bold w/ Blue background) for any version constraint that is different than the most recent.
        This is intended to quickly show which environments are still "behind" during a roll-out.

2.5
----
cruhl - Updated README.md to markdown formatting.
	Fixed error when constrained cookbook does not exist on server.
	
2.6
----
cruhl - First shot at making this into a Gem.

2.7
----
cruhl - Made a gem that actually works.
	Updated README accordingly.

2.7.2
-----
cruhl - Changed updated to use Chef::CookbookVersion#list, rather than  #latest_cookbooks.

2.7.3
-----
cruhl - re-sorted cookbooks, which changed with 2.7.2

2.7.4
-----
cruhl - Added option to select specific cookbooks
      - Changed options to avoid conflict with knife options

2.7.5
-----
cruhl - Added yellow highlight to denote cookbook versions which do not exist on the chef server

2.8.0
-----
cruhl - Added basics for output in html

2.8.1
-----
cruhl - finalized html output, updated README.md

2.8.2
-----
cruhl - Adjusted colors for clarity

2.8.3
-----
cruhl - Corrected hardcoded server name on html output.

2.8.5
-----
nshemonsky - fix populating of envorder array
cruhl - allow envorder to be either string or array

2.8.6
-----
cruhl - Fixed incorrect envorder test.
B
A
D
cruhl - corrected envorder test
