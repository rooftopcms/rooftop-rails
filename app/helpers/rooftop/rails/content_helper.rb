module Rooftop
  module Rails
    # A mixin helper to make it easier to deal with content coming out of Rooftop.
    # For example, rendering relative links in the context of your application.
    module ContentHelper

      # Parse content and replace links from Rooftop with links to your resources.
      # We introspect your routes using Rooftop::Rails::RouteResolver, which also gives you scope for
      # manually overriding something, by setting Rooftop::Rails.configuration.resource_route_mapping.
      # See the readme for more info.

      # @param content [String] the content you want to parse, e.g. an html field from Rooftop.
      # @return [String] the HTML, parsed to point to your URL structure.
      def parse_links(content)
        _fragment = Nokogiri::HTML.fragment(content, 'UTF-8')
        _fragment.css("a[data-rooftop-link-type]").each do |a|
          # build up the slug path for the resource we're linking to
          if a['data-rooftop-link-ancestor-slugs'] #we have a nested resource, we need to build up the slug path
            path = a['data-rooftop-link-ancestor-slugs'].split(",").push(a['data-rooftop-link-slug'])
            resource_id = path.join("/")
          else
            resource_id = a['data-rooftop-link-slug']
          end

          a['href'] = Rooftop::Rails::RouteResolver.new(a['data-rooftop-link-type'], resource_id).resolve
        end
        _fragment.to_html
      end

      def parse_content(content)
        parse_links(content).html_safe
      end
    end
  end
end