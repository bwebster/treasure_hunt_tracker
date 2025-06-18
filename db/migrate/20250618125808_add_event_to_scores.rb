class AddEventToScores < ActiveRecord::Migration[8.0]
  def change
    add_reference :scores, :event, type: :uuid, foreign_key: true
  end
end
