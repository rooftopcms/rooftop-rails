Rails.application.routes.draw do
  resources :webhooks, only: [:create], defaults: { format: :json } do
    collection do
      scope constraints: RooftopRails::DevelopmentConstraint do
        get "/debug", to: "webhooks#debug"
      end
    end
  end

  resources :preview, only: [:create], defaults: { format: :json }
end
