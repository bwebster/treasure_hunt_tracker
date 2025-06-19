# frozen_string_literal: true

# == Schema Information
#
# Table name: scores
#
#  id                :string           not null, primary key
#  score             :integer          not null
#  score_type        :string           not null
#  source            :string
#  created_at        :datetime
#  event_id          :uuid
#  location_id       :uuid
#  rfid_tag_id       :uuid             not null
#  tracking_event_id :uuid
#
# Indexes
#
#  index_scores_on_event_id           (event_id)
#  index_scores_on_location_id        (location_id)
#  index_scores_on_rfid_tag_id        (rfid_tag_id)
#  index_scores_on_tracking_event_id  (tracking_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (rfid_tag_id => rfid_tags.id)
#  fk_rails_...  (tracking_event_id => tracking_events.id)
#

class Score < ApplicationRecord
  belongs_to :rfid_tag
  belongs_to :event
  belongs_to :location
  belongs_to :tracking_event

  scope :for_tag_id, ->(tag_id) { where(rfid_tag_id: tag_id) }
end
