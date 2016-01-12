module Rooftop
  module Rails
    class Engine < ::Rails::Engine

      isolate_namespace Rooftop::Rails

      config.before_initialize do
        if Rooftop::Rails.configuration.nil?
          Rooftop::Rails.configure {}
        end
      end

      initializer "configure_rooftop", before: :add_entry_mappings do
        Rooftop.configure do |config|
          config.api_token = Rooftop::Rails.configuration.api_token
          config.site_name = Rooftop::Rails.configuration.site_name
          config.extra_headers = Rooftop::Rails.configuration.extra_headers
          config.advanced_options = Rooftop::Rails.configuration.advanced_options
          config.api_path = Rooftop::Rails.configuration.api_path
          config.url = Rooftop::Rails.configuration.url || "https://#{config.site_name}.rooftopcms.io"
          config.perform_caching = Rooftop::Rails.configuration.perform_http_response_caching
          config.cache_store = Rooftop::Rails.configuration.cache_store
          config.cache_logger = Rooftop::Rails.configuration.cache_logger
          config.ssl_options = Rooftop::Rails.configuration.ssl_options
          config.proxy = Rooftop::Rails.configuration.proxy
          config.logger = Rooftop::Rails.configuration.logger
        end
      end

      initializer "add_preview_support" do
        ActiveSupport.on_load(:action_controller) do
          include Rooftop::Rails::Preview
        end
      end

      initializer "add_helpers" do
        ActiveSupport.on_load(:action_view) do
          include Rooftop::Rails::ContentHelper
          include Rooftop::Rails::MenuHelper
        end
      end

      initializer "add_caching_to_rooftop_models" do
        ::Rails.application.eager_load!
        Rooftop::Base.included_classes.each do |klass|
          klass.send(:prepend, Rooftop::Rails::ObjectCache)
        end
      end

      initializer "clear_caches_on_webhook_notification" do
        ActiveSupport::Notifications.subscribe(/rooftop.*/) do |name, start, finish, id, payload|
          Rooftop::Rails::CacheExpirer.expire(payload)
        end
      end
    end
  end
end
