class Rooftop::Rails::WebhooksController < ApplicationController
  # if Rooftop::Rails.configuration.authenticate_webhooks
  #   http_basic_authenticate_with  name: Rooftop::Rails.configuration.webhooks_username,
  #                                 password: Rooftop::Rails.configuration.webhooks_password
  # end

  skip_before_action :verify_authenticity_token, :only => [:create]

  #this is where we receive a webhook, via a POST
  def create
    # Rooftop will POST data to this endpoint, and we can decide what to do with it.
    # The data included in the POST is as follows:

    request.format = :json
    update_type = params[:status]

    # All we do here is publish an ActiveSupport::Notification, which is subscribed to
    # elsewhere. In this gem are subscription options for timestamp or object caching,
    # implement your own and subscribe in an initializer.
    ActiveSupport::Notifications.instrument("rooftop.#{update_type}", params)

    #must return an ok
    render nothing: true
  end

  def debug
    render text: "Debug method works ok"
  end

  private

  def webhook_params
    params.permit!
  end



end