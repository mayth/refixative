Rails.application.routes.draw do
  root 'home#index'

  get  'players/upload', to: 'players#upload'
  post 'players/upload', to: 'players#parse'
  get  'players/confirm', to: 'players#confirm'
  post 'players/register', to: 'players#register'
end
