require 'csv'

class Fuel < ApplicationRecord
  belongs_to :card

  # CSVデータのインポート処理
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # 1. CSVからカード管理番号を取得
      internal_id = row['管理番号']
      next if internal_id.blank?

      # 2. カードを検索（ステータスが active（利用中）のものを優先して探す）
      # find_by(status: :active) で見つからなければ、ステータス不問で検索する
      card = Card.find_by(internal_id: internal_id, status: :active) || Card.find_by(internal_id: internal_id)
      # カードが見つからない場合はスキップ
      next unless card

      # 3. Fuelデータの作成・保存
      # 日付文字列をパースする（"20231001" のような8桁の数字にも対応）
      raw_date = row['給油日時'].to_s
      parsed_date = if raw_date.match?(/\A\d{8}\z/)
                      Time.zone.strptime(raw_date, '%Y%m%d')
                    else
                      Time.zone.parse(raw_date)
                    end rescue nil
      # 日付が不正ならスキップ
      next if parsed_date.nil?

      # ユニーク制約（card_id, filled_at, amount）に基づき、既存データがあれば取得、なければ新規作成
      fuel = find_or_initialize_by(
        card: card,
        filled_at: parsed_date,
        amount: row['金額']
      )
      # その他の項目をセット
      fuel.volume = row['給油量']
      fuel.unit_price = row['単価']
      fuel.store_name = row['給油所名']

      fuel.save
    end
  end
end
