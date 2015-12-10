module Rooftop
  module Rails
    # This mixin adds object caching when you call find(). It overloads the find() method to cache the result, and read that instead if possible.
    module ObjectCache
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Utility method to get the cache key for the instance.
      def cache_key
        "#{self.class.cache_key_base}/#{self.id}"
      end

      module ClassMethods

        # Base of the cache key for this class.
        def cache_key_base
          "rooftop/#{self.to_s.underscore}"
        end

        # Overload the find() method, with caching. Only pass uncached keys to the super method.
        def find(*ids)
          if Rooftop::Rails.configuration.perform_object_caching
            ids.uniq!
            uncached_ids = ids.reject {|i| ::Rails.cache.read("#{cache_key_base}/#{i}").present?}
            [super(*uncached_ids)].flatten.reject(&:blank?).collect do |object|
              ::Rails.logger.debug("Caching #{cache_key_base}/#{object.id}")
              ::Rails.cache.write("#{cache_key_base}/#{object.id}",object)
            end
            all_objects = ids.collect do |id|
              ::Rails.cache.read("#{cache_key_base}/#{id}")
            end

            all_objects.length == 1 ? all_objects.first : all_objects
          else
            super
          end
        end

      end
    end
  end
end