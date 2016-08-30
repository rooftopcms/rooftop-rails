require 'rooftop'
require 'require_all'
require_rel '.'

module Rooftop
  module Rails
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :api_token,
                    :site_name,
                    :advanced_options,
                    :url,
                    :api_path,
                    :extra_headers,
                    :authenticate_webhooks,
                    :webhooks_username,
                    :webhooks_password,
                    :perform_http_response_caching,
                    :cache_store,
                    :cache_logger,
                    :logger,
                    :ssl_options,
                    :proxy,
                    :resource_route_map,
                    :post_type_mapping

      def perform_object_caching=(perform_caching)
        if perform_caching.is_a?(Proc)
          @perform_object_caching = perform_caching
        else
          @perform_object_caching = ->{perform_caching}
        end
      end

      def perform_object_caching
        @perform_object_caching.call
      end

      def initialize
        @authenticate_webhooks = true
        @perform_http_response_caching = ::Rails.configuration.action_controller.perform_caching
        @perform_object_caching = ->{::Rails.configuration.action_controller.perform_caching}
        @cache_store = ::Rails.cache
        @cache_logger = ::Rails.logger
        @ssl_options = {}
        @resource_route_map = {}
        @logger = nil
      end
    end
  end
end
