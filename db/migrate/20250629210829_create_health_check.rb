class CreateHealthCheck < ActiveRecord::Migration[8.0]
  def change
    create_table :health_checks, id: :uuid do |t|
      t.references :location, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
