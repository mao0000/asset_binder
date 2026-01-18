class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    # --- アラートセクション ---
    
    # 1. 車検期限が迫っている車両（60日以内）
    # N+1対策でinspectionsをincludeしておく
    @alert_vehicles = Vehicle.includes(:inspections).all.select do |v|
      expiration = v.inspection_expiration_date
      expiration && (expiration - Date.today).to_i <= 60
    end.sort_by { |v| v.inspection_expiration_date }

    # 2. 受領待ちのカード
    @requesting_cards = Card.where(status: :requesting)


    # --- サマリーセクション ---

    # 3. 今月の給油コスト
    start_date = Time.current.beginning_of_month
    end_date = Time.current.end_of_month
    current_month_fuels = Fuel.where(filled_at: start_date..end_date)
    @current_month_cost = current_month_fuels.sum(:amount)
    
    # 4. 車両総数
    @total_vehicles = Vehicle.count
  end
end
