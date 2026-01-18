Rails.application.routes.draw do
  devise_for :users

  root "dashboards#index"
  resources :dashboards, only: [:index]

  # 車両管理
  resources :vehicles do
    # 車検管理
    resources :inspections, only: :create
  end

  # カード管理
  resources :cards do
    member do
      patch :receive         # 受領ボタン用
      patch :return_to_stock # 返却ボタン用
    end
  end

  # サイドバーの「車検スケジュール」用
  resources :inspections, only: [:index, :show]

  # 給油データ管理
  resources :fuels do
    collection { post :import } # CSVデータのインポート
  end

  # レポート
  resources :reports, only: [:index]
end
