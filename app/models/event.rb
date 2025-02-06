# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_events_on_date  (date) UNIQUE
#

class Event < ApplicationRecord
  has_many :locations, dependent: :destroy

  validates :name, presence: true
  validates :date, presence: true, uniqueness: { message: "already has an event scheduled." }
end
