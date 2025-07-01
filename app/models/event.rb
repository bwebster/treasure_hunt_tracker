# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id         :uuid             not null, primary key
#  date       :date
#  name       :string           not null
#  test_event :boolean          default(FALSE), not null
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

  # Find event given a scanned_at time.  NOTE: the passed in timestamp will be in UTC,
  # so you need to translate it to local time to properly match an event.
  def self.for_scan(scanned_at)
    return nil unless scanned_at

    Event.find_by(date: scanned_at.in_time_zone("America/Chicago").to_date)
  end
end
