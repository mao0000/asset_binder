class AddVehicleTypeToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :vehicle_type, :string
  end
end
