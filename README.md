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
  # Advanced options which you probably won't need
  config.extra_headers = {header: "something", another_header: "something else"} #headers sent with requests for the content
  config.advanced_options = {option: true} # for future use
  # The following settings are only necessary if you're hosting Rooftop yourself.
  config.url = "https://your.rooftop.site" #only necessary for a custom self-hosted Rooftop installation
  config.api_path = "/path/to/api" #only necessary for a custom self-hosted Rooftop installation
end
```
# Use

## Pulling Rooftop content into your Rails application
This gem builds on the `rooftop-ruby` library so please have a look at that project to understand how to integrate Rooftop into your Ruby models. In essence it's as simple as:

```
class YourModel
    include Rooftop::Post
    self.post_type = "your_post_type"
end
```

`YourModel` will now respond to calls like `.first()` to get the first post of type `your_post_type` from Rooftop.

# Roadmap
The project is moving fast. Things on our list include:

* Webhooks controller: respond to incoming requests by caching the latest content
* Model and view caching: Rails needs to be able to render content from a local cache.
* Preview URL: you'll be able to go to preview.your-site.com on your rails site and see draft content from Rooftop.
* Saving content back to Rooftop: definitely doable.
* Forms: GravityForms integration is work-in-progress in Rooftop. We'll include a custom renderer for it in Rails, when it's done.

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
