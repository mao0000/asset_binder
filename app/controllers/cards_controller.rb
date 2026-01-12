class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy, :receive, :return_to_stock]

  def index
    @cards = Card.all.includes(:vehicle)

    if params[:status].present?
      @cards = @cards.where(status: params[:status])
    end

    if params[:office_id].present?
      @cards = @cards.joins(:vehicle).where(vehicles: { office_id: params[:office_id] })
    end

    if params[:query].present?
      @cards = @cards.where("internal_id LIKE ?", "%#{params[:query]}%")
    end
  end

  def new
    @card = Card.new
    # 車両一覧を取得（セレクトボックス用）
    @vehicles = Vehicle.all
  end

  def create
    @card = Card.new(card_params)
    if @card.save
      redirect_to cards_path, notice: "カードの発行申請を登録しました。"
    else
      @vehicles = Vehicle.all
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    @vehicles = Vehicle.all
  end

  def update
    if @card.update(card_params)
      redirect_to @card, notice: "カード情報を更新しました。"
    else
      @vehicles = Vehicle.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to cards_path, notice: "カード情報を削除しました。", status: :see_other
  end

  # 営業所が受領した時の処理
  def receive
    if @card.update(status: :active, received_on: Date.today)
      redirect_to @card, notice: "カードを受領し、利用開始しました。"
    else
      redirect_to @card, alert: "受領処理に失敗しました。"
    end
  end

  # 本部に返却され在庫に戻る時の処理
  def return_to_stock
    if @card.update(status: :stock, vehicle_id: nil, returned_on: Date.today)
      redirect_to cards_path, notice: "カードが本部へ返却され、在庫（フリー）になりました。"
    else
      redirect_to @card, alert: "返却処理に失敗しました。"
    end
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:vehicle_id, :internal_id, :card_number, :issue_type, :status, :remarks)
  end
end
