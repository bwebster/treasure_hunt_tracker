class CreateTrackingEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :tracking_events, id: :uuid do |t|
      t.references :rfid_tag, type: :uuid, null: false, foreign_key: true
      t.jsonb :metadata
      t.datetime :scanned_at

      t.timestamps
    end
  end
end
