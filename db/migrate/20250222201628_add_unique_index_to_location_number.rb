# frozen_string_literal: true

class AddUniqueIndexToLocationNumber < ActiveRecord::Migration[8.0]
  def change
    add_index :locations, %i[event_id number], unique: true
  end
end
