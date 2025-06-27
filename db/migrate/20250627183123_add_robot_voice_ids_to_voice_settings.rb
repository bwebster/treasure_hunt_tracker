class AddRobotVoiceIdsToVoiceSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :voice_settings, :robot_voice_ids, :string
  end
end
