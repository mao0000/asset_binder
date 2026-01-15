class VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vehicle, only: %i[ show edit update destroy ]

  # 車両一覧（トップページ）
  def index
    @vehicles = Vehicle.search(params[:query])
    @vehicles = @vehicles.where(office_id: params[:office_id]) if params[:office_id].present?
  end

  # 車両詳細
  def show
  end

  # 車両登録ページ
  def new
    @vehicle = Vehicle.new
  end

  # 車両登録
  def create
    @vehicle = Vehicle.new(vehicle_params)
    if @vehicle.save
      redirect_to root_path, notice: "車両情報を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 車両編集ページ
  def edit
  end

  # 車両編集保存
  def update
    if @vehicle.update(vehicle_params)
      redirect_to vehicle_path(@vehicle), notice: "車両情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 車両削除
  def destroy
    @vehicle.destroy
    redirect_to root_path, notice: "車両情報を削除しました。", status: :see_other
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end
  
  def vehicle_params
    params.require(:vehicle).permit(:v_location, :v_code, :v_kana, :v_serial, :obe_number_part1, :obe_number_part2, :obe_number_part3, :office_id, :status_id, :first_registration_date, :usage, :usage_type, :gross_weight, :vehicle_type, :inspection_expiration_date).merge(user_id: current_user.id)
  end
end