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

require 'rails_helper'

RSpec.describe Score, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
