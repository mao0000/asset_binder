class Card < ApplicationRecord
  belongs_to :vehicle, optional: true # 車両がない（在庫）状態を許容する

  # enumの定義
  enum issue_type: { initial: 0, reissue: 1 } # 発行区分（0:新規発行, 1:再発行）
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
end
