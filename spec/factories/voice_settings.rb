# frozen_string_literal: true

# == Schema Information
#
# Table name: voice_settings
#
#  id                :uuid             not null, primary key
#  api_key           :string
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
FactoryBot.define do
  factory :voice_setting do
    stability { "9.99" }
    use_speaker_boost { false }
    similarity_boost { "9.99" }
    style { "9.99" }
    speed { "9.99" }
    voice_ids { "MyString" }
  end
end
