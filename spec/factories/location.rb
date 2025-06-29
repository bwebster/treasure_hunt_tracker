# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    name { "location-#{SecureRandom.uuid}" }
    sequence :number
    registration { false }
    display { false }
    event

    trait :registration do
      registration { true }
    end

    trait :display do
      display { true }
    end
  end
end
