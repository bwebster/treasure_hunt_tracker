# == Schema Information
#
# Table name: rfid_tags
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  tag_id     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  label      :string           not null
#
# Indexes
#
#  index_rfid_tags_on_label    (label) UNIQUE
#  index_rfid_tags_on_tag_id   (tag_id)
#  index_rfid_tags_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe RfidTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
