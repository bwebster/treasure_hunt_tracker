class AddUniqueIndexToLocationNumber < ActiveRecord::Migration[8.0]
  def change
    add_index :locations, [:event_id, :number], unique: true
  end
end
