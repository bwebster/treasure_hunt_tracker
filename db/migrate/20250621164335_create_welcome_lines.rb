# frozen_string_literal: true

class CreateWelcomeLines < ActiveRecord::Migration[8.0]
  def change
    create_table :welcome_lines, id: :uuid do |t|
      t.string :text

      t.timestamps
    end
  end
end
