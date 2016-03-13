module Rooftop
  module Rails
    # A class to generate a proper rails route for Rooftop resources.
    #
    # You can configure a custom route in Rooftop::Rails::Configuration.resource_route_map. If you don't,
    # this class will introspect the Rails routes to try and guess. Otherwise it'll return nothing.
    class RouteResolver
      # Create the route resolver, with a type (post, page, whatever) and an optional ID
      attr_accessor :type, :id
      def initialize(type, id=nil)
        @type = type.to_sym
        @id = id
      end

      def resolve
        route_config = Rooftop::Rails.configuration.resource_route_map
        resource_key = @id.nil? ? @type.to_s.pluralize.to_sym : @type
        if route_config[resource_key]
          return route_config[resource_key].try(:call,@id)
        else
          begin
            route_info = ::Rails.application.routes.named_routes[resource_key].defaults
            # once you've called the routes once, you'll have an id. We don't want the previously called one, and in the case of not passing an ID, we want the index method instead of the show method
            route_info.merge!(id: @id) unless @id.nil?
            ::Rails.application.routes.url_helpers.url_for(route_info.merge(only_path: true))
          rescue
            nil
          end
        end
      end


    end
  end
end