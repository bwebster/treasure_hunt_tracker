# frozen_string_literal: true

class AddTestEventToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :test_event, :boolean, default: false, null: false
  end
end
