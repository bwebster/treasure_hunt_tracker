# frozen_string_literal: true

FactoryBot.define do
  factory :rfid_tag do
    label { "Astro-#{SecureRandom.uuid}" }
    tag_id { SecureRandom.uuid }
    user
  end
end