class Inspection < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :inspection_type
  belongs_to :vehicle

  validates :inspection_type_id, presence: true # 車検・3ヶ月点検・12ヶ月点検（現在は車検のみ実装）
  validates :conducted_on,       presence: true # 実施日

  # 実施日を表示用に整形（和暦）
  def display_conducted_on
    return nil unless conducted_on
    
    y = conducted_on.year
    m = conducted_on.month
    d = conducted_on.day
    
    era = if y >= 2019
            y == 2019 ? "令和元年" : "令和#{y - 2018}年"
          else
            "平成#{y - 1988}年"
          end
    
    "#{era}#{m}月#{d}日"
  end

  after_create :update_vehicle_expiration_date

  private

  def update_vehicle_expiration_date
    # 車検（id: 1）の場合のみ、車両の有効期限を更新
    if inspection_type_id == 1
      vehicle.update_inspection_expiration_date(self)
    end
  end
end