# frozen_string_literal: true

class CreateRfidTags < ActiveRecord::Migration[8.0]
  def change
    create_table :rfid_tags, id: :uuid do |t|
      t.references :user, type: :uuid, null: true, foreign_key: true
      t.string :tag_id

      t.timestamps
    end
    add_index :rfid_tags, :tag_id
  end
end
