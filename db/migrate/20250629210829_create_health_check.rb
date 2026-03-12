# frozen_string_literal: true

class CreateHealthCheck < ActiveRecord::Migration[8.0]
  def change
    create_table :health_checks, id: :uuid do |t|
      t.string :location, null: false
      t.timestamps
    end
  end
end
