# frozen_string_literal: true

# == Schema Information
#
# Table name: voice_settings
#
#  id                :uuid             not null, primary key
#  api_key           :string
#  robot_voice_ids   :string
#  similarity_boost  :decimal(, )
#  speed             :decimal(, )
#  stability         :decimal(, )
#  style             :decimal(, )
#  use_speaker_boost :boolean
#  voice_ids         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  model_id          :string
#
class VoiceSetting < ApplicationRecord
  SINGLETON_ID = "1d296973-d532-4f32-b33f-c54346d66bd2"

  validates :voice_ids, presence: true
  validates :model_id, presence: true

  def self.singleton
    find_or_create_by(id: SINGLETON_ID) do |vs|
      vs.voice_ids = "6F5Zhi321D3Oq7v1oNT4" # Hank
      vs.robot_voice_ids = "nPijfmaNgvm5OSN4xM8H" # Android X.Y. Z. - AI Robot of the Future
      vs.stability = 0.75
      vs.similarity_boost = 0.9
      vs.model_id = "eleven_flash_v2"
    end
  end

  def rand_voice
    (voice_ids || "").split(",").sample
  end

  def rand_robotic_voice
    (robot_voice_ids || "").split(",").sample
  end
end
