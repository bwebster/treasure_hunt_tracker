# frozen_string_literal: true

# == Schema Information
#
# Table name: health_checks
#
#  id         :uuid             not null, primary key
#  location   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HealthCheck < ApplicationRecord
end
