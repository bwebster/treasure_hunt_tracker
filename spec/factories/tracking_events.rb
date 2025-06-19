# frozen_string_literal: true

FactoryBot.define do
  factory :tracking_event do
    scanned_at { Time.zone.now }
    submitted_location { "1" }
    location_id { 1 }
    rfid_tag
  end
end