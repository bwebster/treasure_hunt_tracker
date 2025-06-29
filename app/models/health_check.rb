# frozen_string_literal: true

# == Schema Information
#
# Table name: health_checks
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :uuid             not null
#
# Indexes
#
#  index_health_checks_on_location_id  (location_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

class HealthCheck < ApplicationRecord
  belongs_to :location
end
