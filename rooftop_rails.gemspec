$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rooftop_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rooftop_rails"
  s.version     = RooftopRails::VERSION
  s.authors     = ["Paul Hendrick"]
  s.email       = ["paul@errorstudio.co.uk"]
  s.homepage    = ""
  s.summary     = "RooftopRails - Rooftop client for Ruby on Rails"
  s.description = "RooftopRails - Rooftop client for Ruby on Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_dependency "rooftop-ruby-client"
end
