module Rooftop
  module Rails

    # This module adds methods for finding by a nested path of slugs, and generating a
    # nested path of slugs
    module NestedModel

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Get a model from a nested path. Assumes `slug` is the field you'll be finding by.
        # Accepts options for the path delimiter and whether you want to unescape url strings

        # @param path [String] the path - the last of which will be the thing we find
        # @param opts [Hash] options - path delimiter and unescape
        # @return object [Object] an instance of the class this is mixed into
        def find_by_nested_path(path, opts = {})
          options = {delimiter: '/', unescape: false}
          options.merge!(opts)
          path = CGI::unescape(path) if options[:unescape]
          delimiter = options[:delimiter]
          slug = "#{options[:prefix]}#{path}".gsub(/^\//, '').split(delimiter).last
          entities = where(slug: slug)
          entity = entities.to_a.find {|e| e.nested_path == path}
          if entity.nil?
            raise Rooftop::RecordNotFoundError, "Couldn't find #{self} with slug #{slug}"
          else
            return entity
          end
        end
      end

      # Given a field (and optional delimiter), return a path to the current object.
      # e.g. you'd end up with /path/to/page (where this object is 'page')
      # @param [Symbol] the field to use to create the path
      # @param [String] the delimiter to use. Defaults to "/"
      # @return [String] the path as a string
      def nested_path(opts = {})
        options = {delimiter: "/", prefix: ""}
        options.merge!(opts)
        delimiter = options[:delimiter]
        prefix = options[:prefix].empty? ? "" : "#{options[:prefix]}#{delimiter}"
        path = ([slug] + ancestors.collect(&:slug)).reverse.join(delimiter).gsub(prefix,"")
        return path
      end
    end
  end
end
