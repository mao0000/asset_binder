class Vehicle < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  
  attr_accessor :obe_number_part1, :obe_number_part2, :obe_number_part3
  after_initialize :split_obe_number
  before_validation :combine_obe_number
  before_save :set_inspection_cycle_years

  # バリデーション
  validates :v_location, presence: true, length: { maximum: 4 }, format: { with: /\A[ぁ-ん一-龥]+\z/ } # 車両番号（地域）
  validates :v_code,     presence: true, length: { maximum: 3 }, format: { with: /\A[A-Z0-9]+\z/ } # 車両番号（分類番号）
  validates :v_kana,     presence: true, length: { is: 1 },      format: { with: /\A[ぁ-ん]\z/ } # 車両番号（かな）
  validates :v_serial,   presence: true, length: { maximum: 4 }, format: { with: /\A[0-9]+\z/ } # 車両番号（一連番号）
  validates :office_id,  presence: true # 所蔵営業所ID
  validates :status_id,  presence: true # ステータスID
  validates :user_id,    presence: true # 登録者（ユーザーID）
  validates :obe_number, length: { is: 19 }, format: { with: /\A[0-9]+\z/ }, uniqueness: true, allow_blank: true # 車載器管理番号

  # アソシエーション
  belongs_to :user
  belongs_to :office
  belongs_to :status
  has_many :inspections, dependent: :destroy

  # 車載器管理番号を（5桁-8桁-6桁）の形式で表示用に整形
  def formatted_obe_number
    return if obe_number.blank?
    "#{obe_number[0..4]}-#{obe_number[5..12]}-#{obe_number[13..18]}"
  end

  # 初度登録年月を表示用に整形（和暦）
  def display_first_registration_date
    return nil unless first_registration_date
    
    y = first_registration_date.year
    m = first_registration_date.month
    
    era = if y >= 2019
            y == 2019 ? "令和元年" : "令和#{y - 2018}年"
          else
            "平成#{y - 1988}年"
          end
    
    "#{era}#{m}月"
  end

  # 有効期限の満了する日を表示用に整形（和暦）
  def display_inspection_expiration_date
    return nil unless inspection_expiration_date
    
    y = inspection_expiration_date.year
    m = inspection_expiration_date.month
    d = inspection_expiration_date.day
    
    era = if y >= 2019
            y == 2019 ? "令和元年" : "令和#{y - 2018}年"
          else
            "平成#{y - 1988}年"
          end
    
    "#{era}#{m}月#{d}日"
  end

  # 最新の車検履歴を取得（inspection_type_id: 1 が車検）
  def latest_inspection
    inspections.where(inspection_type_id: 1).order(conducted_on: :desc).first
  end

  # 車検履歴登録時に、有効期限満了日を自動更新する
  def update_inspection_expiration_date(inspection)
    return unless inspection.conducted_on
    
    # 車検周期を取得（保存済みまたは再計算）
    years = inspection_cycle_years || calculate_inspection_cycle_years
    return unless years

    # 継続検査の特例判定（有効期限の2ヶ月前から満了日までの間に受けた場合）
    if inspection_expiration_date.present? &&
       inspection.conducted_on >= inspection_expiration_date.prev_month(2) &&
       inspection.conducted_on <= inspection_expiration_date
      # 現在の満了日を基準に更新（満了日 + n年）
      new_expiration = inspection_expiration_date.next_year(years)
    else
      # それ以外（期限切れ・早期実施など）は実施日を基準に更新（実施日 + n年 - 1日）
      new_expiration = inspection.conducted_on.next_year(years).prev_day
    end

    update(inspection_expiration_date: new_expiration)
  end

  # 検索機能
  def self.search(query)
    if query.present?
      where('v_location LIKE :q OR v_code LIKE :q OR v_kana LIKE :q OR v_serial LIKE :q', q: "%#{query}%")
    else
      all
    end
  end

  # 車両番号をまとめて表示（カード管理のセレクトボックス用）
  def plate_number
    "#{v_location} #{v_code} #{v_kana} #{v_serial}"
  end

  private

  # 車検周期を自動計算してセットする
  def set_inspection_cycle_years
    self.inspection_cycle_years = calculate_inspection_cycle_years
  end

  # 車両情報から継続車検の有効期間（年数）を自動判定
  def calculate_inspection_cycle_years
    # 1. 必要な情報が揃っているかチェック（なければ nil を返す）
    return nil unless usage.present? && usage_type.present? && vehicle_type.present?

    # 2. 事業用なら一律 1年
    return 1 if usage_type == '事業用'

    # 3. 貨物・乗合・特種の場合
    if ['貨物', '乗合', '特種'].include?(usage)
      # 軽自動車なら 2年、それ以外は 1年
      return vehicle_type == '軽自動車' ? 2 : 1
    end

    # 4. それ以外（自家用乗用車など）は 2年
    2
  end

  # DBから読み込んだ車載器管理番号を表示用に3分割する
  def split_obe_number
    return if obe_number.blank?
    self.obe_number_part1 = obe_number[0..4]
    self.obe_number_part2 = obe_number[5..12]
    self.obe_number_part3 = obe_number[13..18]
  end

  # フォームから送信された3分割の車載器管理番号を結合してDB保存用にする
  def combine_obe_number
    return unless obe_number_part1 || obe_number_part2 || obe_number_part3
    self.obe_number = "#{obe_number_part1}#{obe_number_part2}#{obe_number_part3}"
  end
end
