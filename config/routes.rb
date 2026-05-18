Rails.application.routes.draw do
  resources :themes
  resources :users
  resources :values
  resources :images
  get 'main/index'
  get 'main/help'
  get 'main/contacts'
  get 'main/about'

  namespace :api do
    get 'next_image', to: 'api#next_image'
    get 'prev_image', to: 'api#prev_image'
  end

  get 'work', to: 'work#index', as: 'work'
  get 'choose_theme', to: 'work#choose_theme', as: 'choose_theme'
  post 'display_theme', to: 'work#display_theme', as: 'display_theme'
  root 'work#index'
  #root 'main#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
