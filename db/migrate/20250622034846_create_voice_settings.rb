# frozen_string_literal: true

class CreateVoiceSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :voice_settings, id: :uuid do |t|
      t.decimal :stability
      t.boolean :use_speaker_boost
      t.decimal :similarity_boost
      t.decimal :style
      t.decimal :speed
      t.string :voice_ids
      t.string :model_id

      t.timestamps
    end
  end
end
