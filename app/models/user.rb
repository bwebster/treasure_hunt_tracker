# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  username   :string
#  first_name :string
#  last_name  :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
  has_many :rfid_tags
end
