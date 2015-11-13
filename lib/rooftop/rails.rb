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
                    :preview_username,
                    :preview_password,
                    :preview_domain,
                    :enable_preview_domain,
                    :perform_caching,
                    :cache_store,
                    :cache_logger,
                    :ssl_options,
                    :proxy

      def initialize
        @authenticate_webhooks = true
        @perform_caching = ::Rails.configuration.action_controller.perform_caching
        @cache_store = ::Rails.cache
        @cache_logger = ::Rails.logger
        @ssl_options = {}
      end
    end
  end
end
