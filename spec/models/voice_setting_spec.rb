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
require "rails_helper"

RSpec.describe VoiceSetting, type: :model do
  describe ".rand_voice" do
    it "returns a random value" do
      model = FactoryBot.build(:voice_setting, voice_ids: "a,b,c")
      expect(%w[a b c]).to include(model.rand_voice)
    end
  end

  describe ".rand_robotic_voice" do
    it "returns a random value" do
      model = FactoryBot.build(:voice_setting, robot_voice_ids: "a,b,c")
      expect(%w[a b c]).to include(model.rand_robotic_voice)
    end
  end
end
