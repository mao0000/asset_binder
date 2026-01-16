class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 集計期間（過去1年間）
    start_date = 1.year.ago.beginning_of_month
    end_date = Time.current.end_of_month

    # 期間内の給油データを取得（N+1問題対策でinclude）
    fuels = Fuel.includes(card: :vehicle)
                .where(filled_at: start_date..end_date)
                .order(filled_at: :desc)

    # 1. 月別集計
    # { "2023年10月" => { amount: 50000, volume: 300, ... }, ... }
    @monthly_stats = fuels.group_by { |f| f.filled_at.strftime("%Y年%m月") }
                          .transform_values do |data|
                            total_amount = data.sum(&:amount)
                            total_volume = data.sum(&:volume)
                            {
                              amount: total_amount,
                              volume: total_volume,
                              count: data.count,
                              # 給油量がある場合のみ単価を計算（ゼロ除算回避）
                              avg_price: total_volume > 0 ? (total_amount / total_volume).round(1) : 0
                            }
                          end

    # 2. 営業所別集計（金額の降順）
    @office_stats = fuels.group_by { |f| f.card&.vehicle&.office&.name || "未所属/不明" }
                         .transform_values { |data| data.sum(&:amount) }
                         .sort_by { |_, amount| -amount } # 金額が多い順にソート

    # 3. 車両別ワーストランキング（金額の降順）
    @vehicle_ranking = fuels.group_by { |f| f.card&.vehicle }
                            .reject { |vehicle, _| vehicle.nil? } # 車両紐付けがないデータは除外
                            .transform_values { |data| data.sum(&:amount) }
                            .sort_by { |_, amount| -amount }
                            .first(5)

    # 4. グラフ用データ（月昇順）
    # @monthly_stats は降順（新しい順）になっているので、reverseして昇順（古い順）にする
    @chart_data = {
      labels: @monthly_stats.keys.reverse,
      datasets: [{
        label: '給油金額',
        data: @monthly_stats.values.map { |d| d[:amount] }.reverse,
        backgroundColor: 'rgba(59, 130, 246, 0.5)', # Tailwind blue-500
        borderColor: 'rgb(59, 130, 246)',
        borderWidth: 1
      }]
    }
  end
end