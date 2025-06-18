class AddLocationToScore < ActiveRecord::Migration[8.0]
  def change
    add_reference :scores, :location, type: :uuid,foreign_key: true
  end
end
