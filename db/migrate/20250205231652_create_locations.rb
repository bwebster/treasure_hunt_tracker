class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :name
      t.references :event, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :locations, [:event_id, :name], unique: true
  end
end
