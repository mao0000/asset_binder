class AddFirstRegistrationDateToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :first_registration_date, :date
  end
end