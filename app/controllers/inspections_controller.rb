class InspectionsController < ApplicationController
  before_action :authenticate_user!

  # 車検スケジュール一覧（サイドバーから）
  def index
    # 車検期限が近い順に並べ替え（期限がないものは最後に）
    scope = Vehicle.includes(:inspections)
    scope = scope.where(office_id: params[:office_id]) if params[:office_id].present?
    scope = scope.search(params[:query])

    @vehicles = scope.all.sort_by do |v|
      v.inspection_expiration_date || Date.new(2999, 12, 31)
    end
  end

  # 点検履歴の登録
  def create
    @vehicle = Vehicle.find(params[:vehicle_id])
    @inspection = @vehicle.inspections.build(inspection_params)
    
    if @inspection.save
      redirect_to vehicle_path(@vehicle)
    else
      redirect_to vehicle_path(@vehicle), alert: "登録に失敗しました。入力内容を確認してください。"
    end
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end

  private

  def inspection_params
    params.require(:inspection).permit(:inspection_type_id, :conducted_on, :memo)
  end
end
