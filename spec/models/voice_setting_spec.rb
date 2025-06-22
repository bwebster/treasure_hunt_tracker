# frozen_string_literal: true

# == Schema Information
#
# Table name: voice_settings
#
#  id                :uuid             not null, primary key
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
  pending "add some examples to (or delete) #{__FILE__}"
end
