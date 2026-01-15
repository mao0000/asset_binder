class CreateFuels < ActiveRecord::Migration[7.1]
  def change
    create_table :fuels do |t|
      t.references :card, null: false, foreign_key: true # どのカードによる給油か
      t.datetime :filled_at   # 給油日時
      t.integer :amount       # 金額
      t.float :volume         # 給油量（L)
      t.integer :unit_price   # 単価
      t.string :store_name    # 給油所名

      t.timestamps
    end
    # 重複インポート防止のため、カード・日時・金額の組み合わせにインデックスを貼る
    add_index :fuels, [:card_id, :filled_at, :amount], unique: true, name: 'idx_fuel_uniqueness'
  end
end