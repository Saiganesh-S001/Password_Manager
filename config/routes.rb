Rails.application.routes.draw do
  get "shared_access/create", as: :create_shared_access
  get "shared_access/destroy", as: :destroy_shared_access
  resources :password_records
  resources :shared_access, only: [ :create, :destroy ]
  # resources :shared_password_records, only: [:create, :destroy]
  devise_for :users

  mount API => "/"
  mount GrapeSwaggerRails::Engine => "/swagger"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "password_records#index", as: :root

  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  get "verify_security", to: "security#verify", as: :verify_security
  post "verify_security", to: "security#check", as: :check_security
end
