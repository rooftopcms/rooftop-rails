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

        # Redeclare the find() method, with caching. Only pass uncached keys to the super method.
        def find(*ids)
          if Rooftop::Rails.configuration.perform_object_caching
            ids.uniq!
            uncached_ids = ids.reject {|i| ::Rails.cache.read("#{cache_key_base}/#{i}").present?}
            [super(*uncached_ids)].flatten.reject(&:blank?).collect do |object|
              ::Rails.logger.debug("Caching #{cache_key_base}/#{object.id}")
              ::Rails.cache.write(object.cache_key,object)
            end
            all_objects = ids.collect do |id|
              ::Rails.cache.read("#{cache_key_base}/#{id}")
            end

            all_objects.each {|o| o.run_callbacks(:find)}
            all_objects.length == 1 ? all_objects.first : all_objects
          else
            super
          end
        end

        def where(args)
          if Rooftop::Rails.configuration.perform_object_caching
            #Sort the arguments, and any keys which are arrays
            args = Hash[args.sort.each {|k,v| v.sort! if v.is_a?(Array)}]
            # Generate a hash for keying the cache of the results
            args_hash = Digest::MD5.hexdigest(args.to_s)
            cache_key = "#{cache_key_base}/collection_query/#{args_hash}"
            # first see if we have a collection which matches the args
            cached_collection = ::Rails.cache.read(cache_key)
            # if it's present, then we can return it directly.
            if cached_collection.present?
              ::Rails.logger.debug("Returning cached collection for #{cache_key}")
              cached_collection.each {|o| o.run_callbacks :find}
              return cached_collection
            else
              # If not, then we need to call super() to get it from the API
              collection = super(args)
              # and write it into the cache
              ::Rails.cache.write(cache_key,collection)
              # We also iterate over the collection and cache each object, and cache the argument hash against each object
              collection.each do |object|
                # This is a bit funky and circular. We store an array of hashes for queries to which this object belongs.
                # If the object cache needs to be removed, we can iterate through those hashes and clear the collection caches too.
                collection_query_hash_key = "#{object.cache_key}/collection_hashes"
                collection_hashes = ::Rails.cache.read(collection_query_hash_key) || []
                collection_hashes << args_hash
                ::Rails.cache.write(collection_query_hash_key, collection_hashes)
                # this is the object cache - i.e. it'll respond with a cache lookup for Page.find(14) or whatever
                ::Rails.cache.write(object.cache_key,object)
                ::Rails.logger.debug("Written cached collection for #{object.cache_key}")
              end
              collection
            end
          else
            super
          end
        end

        alias_method :find_by, :where

        def all(args = {})
          #TODO this is identical to where, above, but the super() is different. Refactor out to DRY
          if Rooftop::Rails.configuration.perform_object_caching
            #Sort the arguments, and any keys which are arrays
            args = Hash[args.sort.each {|k,v| v.sort! if v.is_a?(Array)}]
            # Generate a hash for keying the cache of the results
            args_hash = Digest::MD5.hexdigest(args.to_s)
            cache_key = "#{cache_key_base}/collection_query/#{args_hash}"
            # first see if we have a collection which matches the args
            cached_collection = ::Rails.cache.read(cache_key)
            # if it's present, then we can return it directly.
            if cached_collection.present?
              ::Rails.logger.debug("Returning cached collection for #{cache_key}")
              cached_collection.each {|o| o.run_callbacks :find}
              return cached_collection
            else
              # If not, then we need to call super() to get it from the API
              collection = super(args)
              # and write it into the cache
              ::Rails.cache.write(cache_key,collection)
              # We also iterate over the collection and cache each object, and cache the argument hash against each object
              collection.each do |object|
                # This is a bit funky and circular. We store an array of hashes for queries to which this object belongs.
                # If the object cache needs to be removed, we can iterate through those hashes and clear the collection caches too.
                collection_query_hash_key = "#{object.cache_key}/collection_hashes"
                collection_hashes = ::Rails.cache.read(collection_query_hash_key) || []
                collection_hashes << args_hash
                ::Rails.cache.write(collection_query_hash_key, collection_hashes)
                # this is the object cache - i.e. it'll respond with a cache lookup for Page.find(14) or whatever
                ::Rails.cache.write(object.cache_key,object)
                ::Rails.logger.debug("Written cached collection for #{object.cache_key}")
              end
              collection
            end
          else
            super
          end
        end

        # A method to expire the relevant caches for a collection of objects or ids
        # @param args [Array] of either objects which respond to `.id`, or ids themselves
        def expire_cache_for(*args)
          args = args.collect {|a| a.respond_to?(:id) ? a.id : a}
          # the caches we need to clear are:
          # - the object cache
          # - any collection caches which included this object
          args.each do |id|
            object_cache_key = "#{cache_key_base}/#{id}"
            collection_keys = (::Rails.cache.read("#{object_cache_key}/collection_hashes") || []).collect do |hash|
              "#{cache_key_base}/collection_query/#{hash}"
            end
            collection_keys << "#{object_cache_key}/collection_hashes"
            [collection_keys + [object_cache_key]].flatten.each do |key|
              ::Rails.cache.delete(key)
            end

          end


        end

      end
    end
  end
end