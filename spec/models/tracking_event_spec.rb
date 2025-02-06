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

require 'rails_helper'

RSpec.describe TrackingEvent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
