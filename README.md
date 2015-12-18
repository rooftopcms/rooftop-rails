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
 
## Nested resources
You probably have one (or more) nested post types in your Rooftop setup. The most obvious one is pages, but you might equally well have product categories or something similar.
  
There are 2 problems this presents for consuming in Rails:

* You need to find a resource from a `/nested/path/of/slugs` (where `slugs` in this case is the slug of the resource you want).
* You need to validate that the path you're provided matches the resource. Otherwise the path `/slugs` would equally well work for the resource, while being wrong.
   
You also need to be able to generate the path for a resource, so you can build URLs and things.

### Rooftop::Rails::NestedModel
`Rooftop::Rails::NestedModel` is a _model_ mixin which does the following:

* Defines a class method `find_by_nested_path()` which, when given a path, find an instance by slug if there is one (and raises `Rooftop::RecordNotFound` if there isn't one).
* Defines an instance method `nested_path()` which returns the nested path to the object you're calling it on.

```
class Page
   include Rooftop::Rails::NestedModel
end

p = Page.find_by_nested_path("/nested/path/of/slugs") # returns the Page which has a slug of 'slugs' in this case.

p.nested_path #returns "/nested/path/of/slugs"

```

### Rooftop::Rails::NestedResource
This is a _controller_ mixin which does the following:

* Defines a class method on your controller called `nested_rooftop_resource` with which you can define the name of your nested model
* Adds a dynamically-named `find_[your resource name]` method, to find the model from the path
* Adds another dynamically-named `validate_[your resource name]` method to validate that the path provided matches the one for the model.
* Adds a utility method `find_and_validate_[your resource name]` because typing is boring.
* _mixes Rooftop::Rails::NestedModel into your model_ so you don't have to. Doesn't hurt if you have, though.

A few of important notes:

1. You need to call `find_and_validate_[your resource name]` (or just find) in a before_action
2. The controller needs to have the path passed to is as `params[:nested_path]`
3. The only field you can find by is `slug`. This probably makes sense because it's how you'd construct URLs in any case.

```
# in your routes
Rails.application.routes.draw do
    # some route definitions in here, followed by...
    match "/*nested_path", via: [:get], to: "pages#show" #note that this is a greedy route

# in your controller
class PagesController < ActionController::Base
    include Rooftop::Rails::NestedResource
    nested_rooftop_resource :page #this mixes Rooftop::Rails::NestedModel into your model, and sets up the `find_` and `validate_` methods
    before_action :find_and_validate_page, only: :show #we only do it for the `show` method because that's where the route points.
     
    def show
        #in here, do your showing stuff; you have access to @page courtesy of the finder method above
    end
end
```

If you make a call to `pages#show` with a slug which is invalid, you get a `Rooftop::ResourceNotFound` error.

If you make a call which ends in a real slug, but the rest of the path isn't right, you get a `Rooftop::Rails::AncestorMismatch` error.

## Parsing Content - how Rooftop handles links to content
Because every project has a different URL structure, it's not possible to customise links in content when they come out of the Rooftop API. For example, you might have pages at `/pages/[slug]` in this project, and `/[slug]` in another. Similarly there's no way you could customise the data for custom post types. So we make links to internal content generic, using data attributes.

### An example link
Say you have a link in some Rooftop content pointing to a custom post type called 'Product Plans', and an entry with a slug called 'enterprise'. The default url structure for this in WordPress would be `/archives/product_plans/enterprise`. Not very useful for your Rails app:

```
<a href="/archives/product_plans/enterprise" class="something">A link to our Enterprise plan</a>
```
  
To fix this, we parse the URLs before the content is presented to the API, so that you get a link in your content like this:
 
```
<a data-rooftop-link-type="product_plan" data-rooftop-link-id="54" data-rooftop-link-slug="enterprise" class="something">A link to our Enterprise plan</a>
```

### How to get links pointing to the right place in your Rails app
That link above, with its data attributes, is nice and flexible, but we can do better. We can introspect your routes and add an `href` attribute pointing to the right place. When you include the `Rooftop::Rails` gem in your project, you get a helper you can use like this:

```
# In your Page model
class Page
    include Rooftop::Page
end

# In your routes
resources :product_plans
# or even
resource :product_plans, path: "our_awesome_products"

# In your controller
@page = Page.first #pretending here that the Page returned is the one with the link in its content

# In your view (or elsewhere)
<div class="some-container-for-your-content>
    <%= parse_content(@page.fields.content)%>
</div>
```

You will see that your content now has links which point to the correct place.

### The RouteResolver class
To make this work, this gem includes a class called Rooftop::Rails::RouteResolver which takes a resource type (:product_plan in this case) and an optional id. It returns the result from url_for, having looked at the routes you've set up.

### Adding custom routes for parsing
If you want to add a custom route for parsing content - say, for example, a non-restful route, or maybe even a route to another application altogether, you can configure this as follows:

```
# in your initializer
Rooftop::Rails.configure do |config|
    # your other config options in here
    config.resource_route_mapping = {
        product_plan: ->(plan) {} # do something in this lambda which, when called, returns the url you want.
    }
```

## routes.rb
Mount the Rooftop::Rails engine at your preferred url:

```
mount Rooftop::Rails => '/rooftop' #feel free to choose a different endpoint name
```

This will give you 2 routes:

`/rooftop/webhooks` - the URL for contentful to post back to.
`/rooftop/webhooks/debug` - a development-only URL to check you have mounted the engine properly :-)

## The webhooks controller - how to receive webhook calls
The webhooks controller uses [Rails instrumentation](http://edgeguides.rubyonrails.org/active_support_instrumentation.html) to notify other code that something has changed.
 
By default, object caches (including collections called with `.where()` or `.find()` are cleared, but you can hook into the notification to do whatever you fancy.

In an initializer, do this:

```
ActiveSupport::Notifications.subscribe(/rooftop.*/) do |name, start, finish, id, payload|
# payload will be a hash, which looks like this:
#{"id"=>"10", "blog_id"=>"115", "sub_domain"=>"your_subdomain", "type"=>"your_post_type", "status"=>"publish"}
  
  #if you want to access the class associated with a custom post type, you can use this:
  if Rooftop.configuration.post_type_mapping[content_type].present?
    klass = Rooftop.configuration.post_type_mapping[content_type]
  else
    klass = content_type.classify.constantize
  end
  
  #then do whatever you want with klass here.
end
```

  
# Roadmap
The project is moving fast. Things on our list include:

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
