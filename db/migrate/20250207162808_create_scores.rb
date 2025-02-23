class CreateScores < ActiveRecord::Migration[8.0]
  def change
    create_table :scores, id: :string do |t|
      t.integer :score, null: false
      t.references :rfid_tag, type: :uuid, foreign_key: true, null: false
      t.string :score_type, null: false
    end
  end
end
