# frozen_string_literal: true

class AddLabelToRfidTag < ActiveRecord::Migration[8.0]
  def change
    add_column :rfid_tags, :label, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_index :rfid_tags, :label, unique: true
  end
end
