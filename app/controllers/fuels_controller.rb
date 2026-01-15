class FuelsController < ApplicationController
  # 給油データ一覧
  before_action :authenticate_user!
  before_action :set_fuel, only: [:edit, :update, :destroy]

  def index
    # 給油日時が新しい順に表示
    @fuels = Fuel.includes(card: :vehicle).order(filled_at: :desc)
  end

  def new
    @fuel = Fuel.new
    # 利用中(active)のカードのみを選択肢として取得
    @cards = Card.where(status: :active).includes(:vehicle)
  end

  def create
    @fuel = Fuel.new(fuel_params)
    if @fuel.save
      redirect_to fuels_path, notice: "給油記録を登録しました。"
    else
      @cards = Card.where(status: :active).includes(:vehicle)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # 編集時は、現在紐付いているカードも含めて選択肢を表示する
    @cards = Card.where(status: :active).or(Card.where(id: @fuel.card_id)).includes(:vehicle)
  end

  def update
    if @fuel.update(fuel_params)
      redirect_to fuels_path, notice: "給油記録を更新しました。"
    else
      @cards = Card.where(status: :active).or(Card.where(id: @fuel.card_id)).includes(:vehicle)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fuel.destroy
    redirect_to fuels_path, notice: "給油記録を削除しました。", status: :see_other
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

  private

  def set_fuel
    @fuel = Fuel.find(params[:id])
  end

  def fuel_params
    params.require(:fuel).permit(:card_id, :filled_at, :amount, :volume, :unit_price, :store_name)
  end
end
