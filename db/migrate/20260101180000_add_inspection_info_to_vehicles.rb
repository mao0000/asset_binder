class AddInspectionInfoToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :inspection_cycle_years, :integer
    add_column :vehicles, :inspection_expiration_date, :date
  end
end
