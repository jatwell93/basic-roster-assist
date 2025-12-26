Rails.application.routes.draw do
  devise_for :users

  # Roster management routes
  resources :rosters, only: [ :index, :show, :new ]

  # Clock-in routes for staff PIN verification
  get "clock_in", to: "clock_ins#new", as: :new_clock_in
  post "clock_in", to: "clock_ins#create"

  # Admin-only award management routes
  constraints ->(request) { request.env["warden"].user&.admin? } do
    resources :awards
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "rosters#index"
end
