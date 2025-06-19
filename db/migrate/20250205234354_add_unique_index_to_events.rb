# frozen_string_literal: true

class AddUniqueIndexToEvents < ActiveRecord::Migration[8.0]
  def change
    add_index :events, :date, unique: true
  end
end
