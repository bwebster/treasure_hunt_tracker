# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { "name-#{SecureRandom.uuid}" }
    date { Time.zone.today }

    trait :test_event do
      test_event { true }
    end
  end
end
