# == Schema Information
#
# Table name: rfid_tags
#
#  id         :uuid             not null, primary key
#  label      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tag_id     :string
#  user_id    :uuid
#
# Indexes
#
#  index_rfid_tags_on_label    (label) UNIQUE
#  index_rfid_tags_on_tag_id   (tag_id)
#  index_rfid_tags_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe RfidTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
