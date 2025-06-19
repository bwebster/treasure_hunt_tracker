# frozen_string_literal: true

class UpdateRfidTagLabelToBeNonNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :rfid_tags, :label, false
  end
end
