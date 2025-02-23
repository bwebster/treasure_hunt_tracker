class AddNumberToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :number, :integer, null: true
  end
end
