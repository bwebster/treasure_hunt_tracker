class AddLocationToTrackingEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :tracking_events, :submitted_location, :string, null: true
    add_reference :tracking_events, :location, type: :uuid, foreign_key: true
  end
end
