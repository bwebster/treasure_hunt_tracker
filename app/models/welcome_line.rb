# == Schema Information
#
# Table name: welcome_lines
#
#  id         :uuid             not null, primary key
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class WelcomeLine < ApplicationRecord
end
