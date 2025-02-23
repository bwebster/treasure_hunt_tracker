Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :api do
    resources :tracking_events, only: [:create]
  end

  resources :users, only: [:index, :show, :edit, :update, :new, :create] do
    resources :rfid_tags, only: [:create, :destroy]
  end

  resources :rfid_tags, only: [:index, :edit, :update]

  resources :progress, only: [:index]

  resources :events do
    resources :locations, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :tracking_events, only: [:index]

  get "register" => "rfid_tags#register"

  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount ActionCable.server => "/cable"

  # Defines the root path route ("/")
  root "progress#index"
end
