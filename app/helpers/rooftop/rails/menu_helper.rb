module Rooftop
  module Rails
    module MenuHelper

      # Given a Rooftop::Menus::Item, return a path for it, or nil if we can't.
      def path_for_menu_item(item)
        begin
          # for links elsewhere, return the url as-is
          if item.object_type == "custom"
            return item.url
          end

          # otherwise we need to determine if we have a nested resource
          if item.object_ancestor_slugs.present?
            # we have a nested tree of slugs
            resource_id = item.object_ancestor_slugs.split(",").push(item.object_slug).join("/")
          else
            resource_id = item.object_slug
          end

          return Rooftop::Rails::RouteResolver.new(item.object_type, resource_id).resolve
        rescue
          nil
        end
      end

      def path_matches?(path)
        request.url =~ %r{#{path}}
      end


    end
  end
end