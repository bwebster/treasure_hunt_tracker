# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id           :uuid             not null, primary key
#  name         :string
#  number       :integer
#  registration :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  event_id     :uuid             not null
#
# Indexes
#
#  index_locations_on_event_id             (event_id)
#  index_locations_on_event_id_and_name    (event_id,name) UNIQUE
#  index_locations_on_event_id_and_number  (event_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#

require "rails_helper"

RSpec.describe Location, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
