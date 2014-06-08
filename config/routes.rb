Rails.application.routes.draw do
  devise_for :admins

  root 'home#index'

  resources :players, only: [:show] do
    get  'upload', on: :collection
    post 'upload', on: :collection, action: :parse
    post 'register', on: :collection
  end

  namespace :admin do
    root 'home#index'
    resources :musics
  end
end
