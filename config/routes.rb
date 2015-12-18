Rooftop::Rails::Engine.routes.draw do
  resources :webhooks, only: [:create], defaults: { format: :json } do
    collection do
      scope constraints: Rooftop::Rails::DevelopmentConstraint do
        get "/debug", to: "webhooks#debug"
      end
    end
  end
end
