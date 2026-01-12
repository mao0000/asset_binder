class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.references :vehicle,  foreign_key: true # 車両ID:nil（在庫）もあるので null: false はつけない

      t.string :internal_id, null:false # 管理番号（4桁）:一定条件下で重複可能なためモデル側のバリデーションで調整
      t.string :card_number             # カード番号（16桁）:プログラムの必須情報ではないので空欄可
      t.integer :issue_type, null: false, default: 0 # 発行区分（0:新規発行, 1:再発行）
      t.integer :status,     null: false, default: 0 # ステータス（0:申請中, 1:利用中, 2:在庫, 3:停止）

      t.date :applied_on  # 申請日（本部がカード会社に発行申請した日）
      t.date :received_on # 営業所受領日（営業所がカードを受領して利用可能な状態になった日）
      t.date :returned_on # 本部返却完了日（車両の廃車・売却で在庫に戻ったカードが本部に返却された日）

      t.text :remarks # メモ欄

      t.timestamps
    end

    # 管理番号で検索可能にするためインデックスを追加
    add_index :cards, :internal_id
  end
end
