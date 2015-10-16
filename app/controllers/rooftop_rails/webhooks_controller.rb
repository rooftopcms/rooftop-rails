class Rooftop::Rails::WebhooksController < ::ApplicationController
  def create
    return render text: "CREATE"
  end
end
