module Rooftop
  module Rails
    module RelationCache

      # This method prepends Her::Model::Relation to redefine `fetch`
      #

      def fetch
        if Rooftop::Rails.configuration.perform_object_caching && @parent.ancestors.include?(Rooftop::Base)
          # Sort the arguments - reduces the number of different argument hashes.
          # Note that 2 different arg hashes might actually be the same, with child arrays
          # in a different order. But we won't mess with the order of the child arrays
          # because sometimes that's important.
          args = @params.sort_by {|k,v| k.to_s}.to_h
          # Generate a hash for keying the cache of the results
          args_hash = Digest::MD5.hexdigest(args.to_s)
          cache_key = "#{@parent.cache_key_base}/collection_query/#{args_hash}"
          # first see if we have a collection which matches the args
          cached_collection = ::Rails.cache.read(cache_key)
          # if it's present, then we can return it directly.
          if cached_collection.present?
            ::Rails.logger.debug("Returning cached collection for #{cache_key}")
            cached_collection.each {|o| o.run_callbacks :find}
            return cached_collection
          else
            # If not, then we need to call super to get it from the API
            collection = super
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
    end
  end
end