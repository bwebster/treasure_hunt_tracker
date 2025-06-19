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

class TrackingEvent < ApplicationRecord
  belongs_to :rfid_tag
  has_one :user, through: :rfid_tag
  belongs_to :location, optional: true
  has_one :event, through: :location

  scope :for_tracking_event, ->(event) { where(rfid_tag_id: event.rfid_tag_id) }
  scope :for_location, ->(location) { where(location_id: location.id) }

  delegate :user, to: :rfid_tag, allow_nil: true
  delegate :event, to: :location, allow_nil: true
end
