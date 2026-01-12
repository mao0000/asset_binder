Rails.application.routes.draw do
  devise_for :users
  root "vehicles#index"
  resources :vehicles do
    resources :inspections, only: [:create, :destroy]
  end

  # サイドバーの「車検スケジュール」用
  resources :inspections, only: [:index]
end
