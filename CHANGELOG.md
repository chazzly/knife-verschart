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
