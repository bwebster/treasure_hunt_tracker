# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { "name-#{SecureRandom.uuid}" }
    date { Date.today }
  end
end