RefixativeNext::Application.routes.draw do
  get  "scores/register" => 'scores#new'
  post "scores/register" => 'scores#register'
  # get "home/index"
  root 'home#index'
end
