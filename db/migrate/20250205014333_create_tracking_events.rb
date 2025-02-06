class CreateTrackingEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :tracking_events do |t|
      t.references :rfid_tag, null: false, foreign_key: true
      t.jsonb :metadata
      t.datetime :scanned_at

      t.timestamps
    end
  end
end
