class AddCreatedAtToScores < ActiveRecord::Migration[8.0]
  def change
    add_column :scores, :created_at, :datetime
  end
end
