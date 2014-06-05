Rails.application.routes.draw do
  root 'home#index'

  resources :players, only: %i(new create show)
end
