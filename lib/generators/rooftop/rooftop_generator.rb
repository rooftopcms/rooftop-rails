class RooftopGenerator < ::Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  class_option :api_token, :type => :string, :aliases => "-t", :desc => "Your Rooftop API token", :default => "YOUR_TOKEN_HERE"
  class_option :site_name, :type => :string, :aliases => "-s", :desc => "Your Rooftop subdomain / site name", :default => "YOUR_SITE_NAME_HERE"

  def create_initializer
    @api_token = options[:api_token]
    @site_name = options[:site_name]

    template "initializer.rb.erb", "config/initializers/rooftop.rb"
  end
end