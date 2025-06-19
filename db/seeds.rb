# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

{
  Date.new(2025, 7, 6) => ["Front Entry", "Kids Lobby", "Kids Hallway"],
  Date.new(2025, 7, 13) => ["Front Entry", "Hospitality", "Back Wall"],
  Date.new(2025, 7, 20) => ["Kids Lobby", "Hospitality", "Community Wall"],
  Date.new(2025, 7, 27) => ["Front Entry", "Hospitality", "Kids Hallway"]
}.each_with_index do |(date, locations), index|
  e = Event.find_or_create_by!(name: "Sunday #{index + 1}", date: date)
  Rails.logger.debug "Created event #{e.name} on #{date}"

  Location.find_or_create_by!(name: "Registration", event: e, number: 0, registration: true)

  locations.each_with_index do |loc, idx|
    loc = Location.find_or_create_by!(name: loc, event: e, number: idx + 1)
    e.locations << loc if e.new_record?
    Rails.logger.debug "  Added location #{loc.name}"
  end
end

%w[Amy Blake Charlie Devin Ellie Freddy Gemma Haddie Illia].each do |name|
  u = User.find_or_create_by!(username: name)
  Rails.logger.debug "Created user #{u.username}"
end

5.times do
  tag = RfidTag.create!(tag_id: SecureRandom.hex(4), label: RfidTag.generate_label)
  Rails.logger.debug "Created tag #{tag.tag_id}"
end
