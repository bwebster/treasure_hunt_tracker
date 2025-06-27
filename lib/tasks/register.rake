# frozen_string_literal: true

desc "Simulate RFID registration event"
task register: :environment do
  api_endpoint = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                   "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/tracking_events"
                 else
                   "http://localhost:3000/api/tracking_events"
                 end

  date = ENV.fetch("DATE") { Time.zone.now.in_time_zone("America/Chicago").to_date }
  event = Event.find_by(date:)
  event ||= Event.order(date: :asc).first
  raise "No event found for date #{date}" unless event

  puts "Found event: #{event.name} on #{event.date}"

  number = ENV.fetch("LOCATION") { event.locations.where(registration: true).first&.number }
  location = Location.for_event(event).find_by(number:)
  raise "No location found for number #{number}" unless location

  rfid = RfidTag.create!(tag_id: SecureRandom.uuid[0..6], label: RfidTag.generate_label)
  puts "Registering RFID #{rfid.tag_id} (#{rfid.id}) at location #{location.number} (#{location.id})"

  payload = {
    id: rfid.tag_id,
    loc: location.number
  }

  # Send the HTTP POST request to create a tracking event
  uri = URI(api_endpoint)
  Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")
end
