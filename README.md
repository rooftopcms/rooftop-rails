# Rooftop::Rails
A library to help you use [Rooftop CMS](https://www.rooftopcms.com) in your Ruby on Rails site. Uses the [rooftop-ruby](http://github.com/rooftopcms/rooftop-ruby) library.

# Setup

## Installation

You can either install using [Bundler](http://bundler.io) or just from the command line.

### Bundler
Include this in your gemfile

`gem 'rooftop-rails'`

That's it! This is in active development so you might prefer:

`gem 'rooftop-rails', github: "rooftop/rooftop-rails"`
 
### Using Gem
As simple as:

`gem install rooftop-rails`

## Configuration
Configure Rooftop::Rails in a Rails initializer:

```
Rooftop::Rails.configure do |config|
  config.site_name = "yoursite"
  config.api_token = "your token in here"
  config.perform_caching = false #If you leave this out, Rooftop::Rails will follow whatever you've set in Rails.configuration.action_controller.perform_caching (usually false in development and true in production)
  config.cache_store = Rails.cache #set to the rails cache store you've configured, by default.
  config.cache_logger = Rails.logger #set to the rails logger by default. You might want to set to nil in production to avoid cache logging noise.
  
  config.ssl_options = {
    #This is where you configure your ssl options.
  }
  
  # Advanced options which you probably won't need
  config.extra_headers = {header: "something", another_header: "something else"} #headers sent with requests for the content
  config.advanced_options = {option: true} # for future use
      
  
  # The following settings are only necessary if you're hosting Rooftop yourself.
  config.url = "https://your.rooftop.site" #only necessary for a custom self-hosted Rooftop installation
  config.api_path = "/path/to/api" #only necessary for a custom self-hosted Rooftop installation
end
```
# Use

## Including Rooftop content in your model
This gem builds on the `rooftop-ruby` library so please have a look at that project to understand how to integrate Rooftop into your Ruby models. In essence it's as simple as:

```
class YourModel
    include Rooftop::Post
    self.post_type = "your_post_type"
end
```

`YourModel` will now respond to calls like `.first()` to get the first post of type `your_post_type` from Rooftop.

There's lots more in the Rooftop library docs here: https://github.com/rooftopcms/rooftop-ruby

## Caching responses from the Rooftop API
The API returns cache headers, including etags, for entities. In the `Rooftop` library, the HTTP responses are cached.
 
 By default, `Rooftop::Rails` configures the same cache as you're using in your Rails application, and switches it on or off by following the `Rails.configuration.action_controller.perform_caching` setting from your environment configs. You can always manually override that by setting `perform_caching` manually in your Rooftop::Rails configuration.
 
 

# Roadmap
The project is moving fast. Things on our list include:

* Webhooks controller: respond to incoming requests by caching the latest content: https://github.com/rooftopcms/rooftop-rails/issues/4
* Model and view caching: Rails needs to be able to render content from a local cache: https://github.com/rooftopcms/rooftop-rails/issues/5
* Preview URL: you'll be able to go to preview.your-site.com on your rails site and see draft content from Rooftop: https://github.com/rooftopcms/rooftop-rails/issues/3
* Saving content back to Rooftop: definitely doable: https://github.com/rooftopcms/rooftop-cms/issues/7
* Forms: GravityForms integration is work-in-progress in Rooftop. We'll include a custom renderer for it in Rails, when it's done: https://github.com/rooftopcms/rooftop-rails/issues/6

# Contributing
 Rooftop and its libraries are open-source and we'd love your input.
 
 1. Fork the repo on github
 2.  Make whatever changes / extensions you think would be useful
 3. If you've got lots of commits, rebase them into sensible squashed chunks
 4. Raise a PR on the project
 
 If you have a real desire to get involved, we're looking for maintainers. [Let us know!](mailto: hello@rooftopcms.com).
 

# Licence
Rooftop::Rails is a library to allow you to connect to Rooftop CMS, the API-first WordPress CMS for developers and content creators.

Copyright 2015 Error Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
