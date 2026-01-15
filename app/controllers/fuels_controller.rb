class FuelsController < ApplicationController
  # 給油データ一覧
  before_action :authenticate_user!

  def index
    # 給油日時が新しい順に表示
    @fuels = Fuel.includes(card: :vehicle).order(filled_at: :desc)
  end

  # 給油データのインポート
  def import
    if params[:file].present?
      begin
        Fuel.import(params[:file])
        redirect_to fuels_path, notice: "給油データをインポートしました。"
      rescue => e
        redirect_to fuels_path, alert: "インポートに失敗しました: #{e.message}"
      end
    else
      redirect_to fuels_path, alert: "ファイルを選択してください。"
    end
  end
end
