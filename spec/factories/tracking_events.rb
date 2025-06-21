# frozen_string_literal: true

# == Schema Information
#
# Table name: tracking_events
#
#  id                 :uuid             not null, primary key
#  metadata           :jsonb
#  scanned_at         :datetime
#  submitted_location :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  location_id        :uuid
#  rfid_tag_id        :uuid             not null
#
# Indexes
#
#  index_tracking_events_on_location_id  (location_id)
#  index_tracking_events_on_rfid_tag_id  (rfid_tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (rfid_tag_id => rfid_tags.id)
#
FactoryBot.define do
  factory :tracking_event do
    scanned_at { Time.zone.now }
    submitted_location { "1" }
    location
    rfid_tag
  end
end
