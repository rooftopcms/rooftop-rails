module Rooftop
  module Rails
    # A class to generate a proper rails route for Rooftop resources.
    #
    # You can configure a custom route in Rooftop::Rails::Configuration.resource_route_map. If you don't,
    # this class will introspect the Rails routes to try and guess. Otherwise it'll return nothing.
    class PostTypeResolver
      # Create the route resolver, with a type (post, page, whatever) and an optional ID
      attr_accessor :type
      def initialize(type)
        @type = type.to_sym
      end

      def resolve()
        begin
          if Rooftop.configuration.post_type_mapping[@type].present?
            Rooftop.configuration.post_type_mapping[@type]
          else
            @type.to_s.classify.constantize
          end
        rescue
          nil
        end
      end
    end
  end
end