Rails.application.routes.draw do

  root "homes#top"
  resource :session, only: [:new, :create, :destroy]
  post "session/guest", to: "sessions#guest", as: :guest_session
  #パスワード再設定時に有効化
  #resources :passwords, param: :token
  resources :users, only: [:new, :create, :show, :edit, :update, :destroy]
  resources :recipes do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  namespace :admin do
    root "homes#top"
    resources :users, only: [:index, :show, :edit, :update]
    resources :recipes, only: [:index, :show, :destroy] do
      resources :comments, only: [:index, :destroy]
    end
    resources :purposes, only: [:index, :create, :edit, :update, :destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker


end
