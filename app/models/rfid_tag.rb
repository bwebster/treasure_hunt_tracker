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

class RfidTag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :tracking_events

  validates :tag_id, presence: true, uniqueness: true

  # Generates a random label consisting of a color followed by 4 random digits, zero padded.
  def self.generate_label
    colors = %w[red blue green yellow purple orange black white gray pink]
    "#{colors.sample}-#{format('%04d', rand(10000))}"
  end
end
