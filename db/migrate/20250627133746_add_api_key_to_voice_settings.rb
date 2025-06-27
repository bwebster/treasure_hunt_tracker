class AddApiKeyToVoiceSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :voice_settings, :api_key, :string
  end
end
