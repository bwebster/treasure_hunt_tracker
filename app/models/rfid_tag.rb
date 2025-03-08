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

class RfidTag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :tracking_events

  validates :tag_id, presence: true, uniqueness: true
  validates_presence_of :label
  validates_uniqueness_of :label

  delegate :username, to: :user

  # Generates a random label consisting of a color followed by 4 random digits, zero padded.
  def self.generate_label
    words = %w[Galaxy Ranger Star Astro Lightyear Rocket Nebula Cosmo Lunar Orbit]
    "#{words.sample}-#{rand(100)}"
  end
end
