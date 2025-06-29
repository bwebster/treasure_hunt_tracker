# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :tracking_events, only: [:create]
  end

  resources :users, only: %i[index show edit update new create destroy] do
    resources :rfid_tags, only: %i[create destroy]
  end

  resources :events do
    patch :copy_locations, on: :member

    resources :locations, only: %i[new create edit update destroy]
  end

  resources :rfid_tags, only: %i[index edit update]
  resources :progress, only: [:index]
  resources :tracking_events, only: [:index] do
    get :activity, on: :collection
  end
  resources :scores, only: [:index]
  resources :welcome_lines

  get "voice_settings", to: "voice_settings#edit"
  patch "voice_settings", to: "voice_settings#update"

  get "register", to: "rfid_tags#register"
  get "display", to: "progress#display"
  get "admin", to: "application#admin"
  post "tts", to: "speak#tts"
  post "tts/progress", to: "speak#progress"

  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount ActionCable.server => "/cable"

  # Defines the root path route ("/")
  root "progress#index"
end
