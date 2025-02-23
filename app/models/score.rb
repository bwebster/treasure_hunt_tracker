# == Schema Information
#
# Table name: scores
#
#  id          :string           not null, primary key
#  score       :integer          not null
#  score_type  :string           not null
#  rfid_tag_id :uuid             not null
#
# Indexes
#
#  index_scores_on_rfid_tag_id  (rfid_tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (rfid_tag_id => rfid_tags.id)
#

class Score < ApplicationRecord
  belongs_to :rfid_tag

  scope :for_tag_id, -> (tag_id) { where(rfid_tag_id: tag_id) }
end
