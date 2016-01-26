module Rooftop
  module Rails
    class CacheExpirer
      def self.expire(payload)
        begin
          content_type = payload[:type].to_sym
          if Rooftop.configuration.post_type_mapping[content_type].present?
            klass = Rooftop.configuration.post_type_mapping[content_type]
          else
            klass = content_type.to_s.classify.constantize
          end
          klass.send(:expire_cache_for, payload[:id])
        rescue => e
          raise Rooftop::Rails::UnknownObjectForExpiry, e
        end

      end
    end
  end
end