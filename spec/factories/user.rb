# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { "user-#{SecureRandom.uuid}" }
  end
end
