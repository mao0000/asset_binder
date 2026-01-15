class Card < ApplicationRecord
  belongs_to :vehicle, optional: true # 車両がない（在庫）状態を許容する
  
  # カード番号を4桁ずつに分割
  attr_accessor :card_number_part1, :card_number_part2, :card_number_part3, :card_number_part4
  after_initialize :split_card_number
  before_validation :combine_card_number

  # enumの定義
  enum issue_type: { initial: 0, reissue: 1 } # 発行種別（0:新規発行, 1:再発行）
  enum status: { requesting: 0, active: 1, stock: 2, inactive: 3 } # ステータス（0:申請中, 1:利用中, 2:在庫, 3:停止）

  # バリデーション
  validates :internal_id, presence: true
  # 「有効なカード（申請中・利用中）」の中だけで管理番号が重複しないようにチェック
  validates :internal_id, uniqueness: { scope: :status }, if: -> { requesting? || active? }

  # 本部で「返却完了」ボタンを押した時の処理
  def mark_as_returned!
    update!(
      status: :stock,         # ステータスを在庫に戻す
      vehicle_id: nil,        # 車両との紐付けを解除
      returned_on: Date.today # 返却完了日を記録
    )
  end

  # カードステータスの表示形式
  def status_text
    case status
    when 'requesting' then '申請中'
    when 'active'     then '利用中'
    when 'stock'      then '在庫'
    when 'inactive'   then '停止'
    end
  end

  private

  # カード番号を4桁ずつに分割
  def split_card_number
    # カード番号がnilの場合は処理を中断する
    return if card_number.blank?
    self.card_number_part1 = card_number[0..3]
    self.card_number_part2 = card_number[4..7]
    self.card_number_part3 = card_number[8..11]
    self.card_number_part4 = card_number[12..15]
  end

  # フォームから送信された4分割のカード番号を結合してDB保存用にする
  def combine_card_number
    # 入力がある場合のみ結合する
    return unless card_number_part1.present? || card_number_part2.present? || card_number_part3.present? || card_number_part4.present?
    self.card_number = "#{card_number_part1}#{card_number_part2}#{card_number_part3}#{card_number_part4}"
  end
end
