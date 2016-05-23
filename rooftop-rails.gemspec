$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rooftop/rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rooftop-rails"
  s.version     = Rooftop::Rails::VERSION
  s.authors     = ["Error Studio"]
  s.email       = ["hosting@errorstudio.co.uk"]
  s.homepage    = "https://github.com/rooftopcms/rooftop-rails"
  s.summary     = "Rooftop::Rails - A Rooftop client for Ruby on Rails"
  s.description = "This gem provides utility methods and a mountable engine for Rails applications using the Rooftop gem"
  s.license     = "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "require_all", "~> 1.3"
  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "nokogiri", "~> 1.6"

  s.add_dependency "rooftop", "0.0.8"
end
