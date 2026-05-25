Rails.application.routes.draw do
  # Без локали: health check и служебные маршруты
  get 'up' => 'rails/health#show', as: :rails_health_check

  if Rails.env.production?
    get 'admin/run_seed', to: 'admin#run_seed'
  end

  scope '(:locale)', locale: /ru|en/ do
    resources :themes
    resources :users
    resources :values
    resources :images

    # Сессии
    get 'signup', to: 'users#new'
    get 'signin', to: 'sessions#new'
    post 'signin', to: 'sessions#create'
    delete 'signout', to: 'sessions#destroy'

    # API
    namespace :api do
      get 'next_image', to: 'api#next_image'
      get 'prev_image', to: 'api#prev_image'
      post 'rate_image', to: 'api#rate_image'
    end

    get 'profile', to: 'users#profile'
    patch 'profile/avatar', to: 'users#update_avatar', as: 'profile_avatar'
    delete 'profile/avatar', to: 'users#remove_avatar', as: 'remove_profile_avatar'

    # Рабочая область
    get 'work', to: 'work#index', as: 'work'
    get 'choose_theme', to: 'work#choose_theme', as: 'choose_theme'
    post 'display_theme', to: 'work#display_theme', as: 'display_theme'

    # Главная и информационные страницы
    get 'main/index'
    get 'main/help'
    get 'main/contacts'
    get 'main/about'
    root 'main#index'
  end
end
