class AddRegistrationToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :registration, :boolean, default: false, null: false
  end
end
