Rails.application.routes.draw do
  root 'home#index'

  resources :players, only: [:show] do
    get  'upload', on: :collection
    post 'upload', on: :collection, action: :parse
    post 'register', on: :collection
  end
end
