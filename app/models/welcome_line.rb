# frozen_string_literal: true

require "mustache"

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
  VALID_TEMPLATE_KEYS = %w[username location].freeze

  validates :text, presence: true
  validate :valid_template

  def interpolate(username:, location:)
    Mustache.render(text, { username:, location: })
  end

  private

  def valid_template
    tags = Mustache.templateify(text).tags
    extra = tags - allowed_tags
    errors.add(:text, "contains invalid variables: #{extra.join(', ')}") if extra.present?
  rescue Mustache::Parser::SyntaxError => e
    errors.add(:text, "has invalid syntax: #{e.message}")
  end

  def allowed_tags
    VALID_TEMPLATE_KEYS
  end
end
