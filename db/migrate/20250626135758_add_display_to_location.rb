class AddDisplayToLocation < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :display, :boolean
  end
end
