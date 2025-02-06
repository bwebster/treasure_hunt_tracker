# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  event_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locations_on_event_id           (event_id)
#  index_locations_on_event_id_and_name  (event_id,name) UNIQUE
#

class Location < ApplicationRecord
  belongs_to :event
  has_many :tracking_events, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :event_id, message: "must be unique per event" }
end
