Rails.application.routes.draw do
  get "shared_access/create"
  get "shared_access/destroy"
  resources :password_records
  resources :shared_access, only: [:create, :destroy]
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "password_records#index"

  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  get 'verify_security', to: 'security#verify'
  post 'verify_security', to: 'security#check'

end
