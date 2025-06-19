# frozen_string_literal: true

FactoryBot.define do
  factory :tracking_event do
    scanned_at { Time.zone.now }
    submitted_location { "1" }
    location
    rfid_tag
  end
end
