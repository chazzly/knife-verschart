Gem::Specification.new do |gem|
  gem.name		= 'knife-verschart'
  gem.version		= '2.8.7'
  gem.date		= '2015-06-16'
  gem.summary		= 'Print chart of cookbooks version constraints per environment.'
  gem.description	= 'Plug-in for Chef::Knife to print a chart of all cookbooks and the version constraints contained in each environment. See README.md for more details.  Special option added specifically for cars.com status tool.'
  gem.authors		= ['Chaz Ruhl']
  gem.email		= 'chazzly@gmail.com'
  gem.files		= ['lib/chef/knife/Verschart.rb']
  gem.homepage		= 'https://github.com/chazzly/knife-verschart'
  gem.license		= 'Apache'
end
