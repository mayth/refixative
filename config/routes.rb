RefixativeNext::Application.routes.draw do
  get "scores/register"
  get "home/index"
  root 'home#index'
end
