class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      # 1. 車両基本情報（ナンバープレート情報）
      t.string :v_location, limit: 4, null: false, comment: "地名"
      t.string :v_code,     limit: 3, null: false, comment: "分類番号"
      t.string :v_kana,     limit: 1, null: false, comment: "ひらがな"
      t.string :v_serial,   limit: 4, null: false, comment: "一連指定番号"

      # 2. 所属・ステータス
      t.integer :office_id,  null: false, comment: "所属営業所ID"
      t.integer :status_id,  null: false, default: 1, comment: "稼働ステータスID"

      # 3. その他機器情報
      t.string :obe_number, limit: 19, comment: "車載器管理番号（OBE）"

      t.timestamps
    end

    # 検索頻度が高いナンバー（一連番号）にインデックス
    add_index :vehicles, :v_serial
    # 車番の重複を防ぎたい場合や、フル車番検索を高速化するための複合インデックス
    add_index :vehicles, [:v_location, :v_code, :v_kana, :v_serial], name: "idx_vehicles_full_number"
    # 営業所ごとの絞り込み用
    add_index :vehicles, :office_id
  end
end
