Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup", to: "auth#signup"
      post "login", to: "auth#login"
      post "refresh", to: "auth#refresh"
      post "logout", to: "auth#logout"
      post "guest_login", to: "auth#guest_login"
      post "migrate", to: "auth#migrate_account"
      resources :cards, only: [ :create, :index, :update, :destroy ] do
        collection do
          get :share_cards
          get :topic_cards
        end
        member do
          patch :update_position
          patch :archive
          patch :restore
          post :copy
        end
      end
      resources :report_cards, only: [ :create ]
    end
  end
end
