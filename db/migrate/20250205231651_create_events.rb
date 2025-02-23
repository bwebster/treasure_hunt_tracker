class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events, id: :uuid do |t|
      t.string :name, null: false
      t.date :date

      t.timestamps
    end
  end
end
