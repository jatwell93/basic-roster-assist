Rails.application.routes.draw do
  devise_for :users

  # Roster management routes
  resources :rosters, only: [ :index, :show, :new, :create, :edit, :update ] do
    resources :base_shifts, only: [ :new, :create, :edit, :update, :destroy ]
    collection do
      get :calendar
    end
    member do
      post :generate
      get :available_staff, format: :json
      post :check_conflicts, format: :json
      post :finalize, format: :json
      post :shifts, action: :create_shift, format: :json
      patch :shifts, action: :update_shift, format: :json
      delete :shifts, action: :destroy_shift, format: :json
    end
  end

  # Clock-in routes for staff PIN verification
  get "clock_in", to: "clock_ins#new", as: :new_clock_in
  post "clock_in", to: "clock_ins#create"

  # Admin-only award management routes
  constraints ->(request) { request.env["warden"].user&.admin? } do
    resources :awards do
      collection do
        get :users
        get :assign_award
        post :assign_to_user
        delete :remove_from_user
      end
    end
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
