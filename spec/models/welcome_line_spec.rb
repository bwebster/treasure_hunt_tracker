# frozen_string_literal: true

# == Schema Information
#
# Table name: welcome_lines
#
#  id         :uuid             not null, primary key
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe WelcomeLine, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
