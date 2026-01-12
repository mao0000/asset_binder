class AddDetailsToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :usage, :string #車両用途
    add_column :vehicles, :usage_type, :string #自家用・事業用の別
    add_column :vehicles, :gross_weight, :integer #車両総重量
  end
end