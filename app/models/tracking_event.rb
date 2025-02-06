# == Schema Information
#
# Table name: tracking_events
#
#  id                 :integer          not null, primary key
#  rfid_tag_id        :integer          not null
#  metadata           :jsonb
#  scanned_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  submitted_location :string
#  location_id        :integer
#
# Indexes
#
#  index_tracking_events_on_location_id  (location_id)
#  index_tracking_events_on_rfid_tag_id  (rfid_tag_id)
#

class TrackingEvent < ApplicationRecord
  belongs_to :rfid_tag
  has_one :user, through: :rfid_tag
  belongs_to :location, optional: true
  has_one :event, through: :location

  delegate :user, to: :rfid_tag, allow_nil: true
  delegate :event, to: :location, allow_nil: true
end
