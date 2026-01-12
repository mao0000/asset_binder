class CreateInspections < ActiveRecord::Migration[7.1]
  def change
    create_table :inspections do |t|
      t.references :vehicle,            null: false, foreign_key: true
      t.integer    :inspection_type_id, null: false
      t.date       :conducted_on,       null: false
      t.text       :memo
      t.timestamps
    end
  end
end