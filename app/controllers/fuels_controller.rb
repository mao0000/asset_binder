class FuelsController < ApplicationController
  # 給油データ一覧
  def index
    @fuels = Fuel.all.order(filled_at: :desc)
  end

  # 給油データのインポート
  def import
    Fuel.import(params[:file])
    redirect_to fuels_path, notice: "給油データをインポートしました。"
  end
end
