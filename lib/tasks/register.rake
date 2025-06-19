# frozen_string_literal: true

desc "Simulate RFID registration event"
task register: :environment do
  api_endpoint = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                   "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/tracking_events"
                 else
                   "http://localhost:3000/api/tracking_events"
                 end

  method = ENV.fetch("METHOD", "http").downcase
  date = ENV.fetch("DATE") { Event.order(date: :asc).first.date }
  event = Event.where(date: date).first
  raise "No event found for date #{date}" unless event

  location_number = ENV.fetch("LOCATION") { event.locations.where(registration: true).first.number }
  location = Location.find_by(number: location_number)
  raise "No location found for number #{location_number}" unless location

  rfid = RfidTag.all.sample(1).first
  puts "Registering RFID #{rfid.tag_id} (#{rfid.id}) at location #{location.number} (#{location.id})"

  if method == "http"
    payload = {
      id: rfid.tag_id,
      loc: location.number,
      at: event.date
    }

    # Send the HTTP POST request to create a tracking event
    uri = URI(api_endpoint)
    Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")
  else
    ActionCable.server.broadcast("register_channel", { rfid_id: rfid.id, location_number: location.id })
  end
end
