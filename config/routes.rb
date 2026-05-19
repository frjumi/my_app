Rails.application.routes.draw do
  resources :themes
  resources :users
  resources :values
  resources :images

  # Сессии
  get 'signup', to: 'users#new'          # страница регистрации (уже есть от scaffold)
  get 'signin', to: 'sessions#new'       # страница входа
  post 'signin', to: 'sessions#create'    # обработка входа
  delete 'signout', to: 'sessions#destroy'  # выход

  # API
  namespace :api do
    get 'next_image', to: 'api#next_image'
    get 'prev_image', to: 'api#prev_image'
    post 'rate_image', to: 'api#rate_image'
  end

  get 'profile', to: 'users#profile'
  patch 'profile/avatar', to: 'users#update_avatar', as: 'profile_avatar'
  delete 'profile/avatar', to: 'users#remove_avatar', as: 'remove_profile_avatar'

  # work routes
  get 'work', to: 'work#index', as: 'work'
  get 'choose_theme', to: 'work#choose_theme', as: 'choose_theme'
  post 'display_theme', to: 'work#display_theme', as: 'display_theme'
  #root 'work#index'

  # main routes
  get 'main/index'
  get 'main/help'
  get 'main/contacts'
  get 'main/about'
  root 'main#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  if Rails.env.production?
    get 'admin/run_seed', to: 'admin#run_seed'
  end
end
