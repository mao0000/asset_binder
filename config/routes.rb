Rails.application.routes.draw do
  devise_for :users
  root "vehicles#index"
  resources :vehicles
end
