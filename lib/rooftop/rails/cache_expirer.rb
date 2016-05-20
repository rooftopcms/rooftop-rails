module Rooftop
  module Rails
    class CacheExpirer
      def self.expire(payload)
        begin
          content_type = payload[:type].to_sym
          klass = Rooftop::Rails::PostTypeResolver.new(content_type).resolve
          klass.send(:expire_cache_for, payload[:id])
        rescue => e
          raise Rooftop::Rails::UnknownObjectForExpiry, e
        end

      end
    end
  end
end