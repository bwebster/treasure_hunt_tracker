require 'net/http'
require 'json'
require 'securerandom'

desc "Simulate tracking events"
task :simulate => :environment do
  API_ENDPOINT = ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME") ? "https://#{ENV["HEROKU_APP_DEFAULT_DOMAIN_NAME"]}/api/tracking_events" : "http://localhost:3000/api/tracking_events"
  SIMULATED_EVENT_COUNT = 50 # Adjust the number of tracking events
  DELAY_RANGE = 1..5 # Random delay between events (in seconds)

  rfid_tags = RfidTag.all.sample(20).pluck(:tag_id)
  puts "Found #{rfid_tags.count} existing tags to use"
  rfid_tags += Array.new(20 - rfid_tags.count) { SecureRandom.hex(4) }
  puts "Added #{20 - rfid_tags.count} new tags to use"

  # Fetch all available events with locations
  events = Event.includes(:locations).where.not(locations: { id: nil }).to_a
  if events.empty?
    puts "No events with locations found. Exiting."
    exit
  end

  puts "Starting simulation of #{SIMULATED_EVENT_COUNT} tracking events..."

  SIMULATED_EVENT_COUNT.times do |i|
    event = events.sample # Pick a random event
    location = event.locations.sample # Pick a random location from the event
    while location.registration?
      location = event.locations.sample
    end
    rfid_tag = rfid_tags.sample # Pick a random RFID tag

    payload = {
      id: rfid_tag,
      loc: location.number,
      at: event.date
    }

    # Send the HTTP POST request to create a tracking event
    uri = URI(API_ENDPOINT)
    response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")

    if response.code == "201"
      puts "✔ Event #{i + 1}: RFID #{rfid_tag} scanned at #{location.name} (#{event.name}) at #{event.date}"
    else
      puts "❌ Event #{i + 1} failed: #{response.body}"
    end

    # Wait for a random amount of time before the next request
    sleep(rand(DELAY_RANGE))
  end

  puts "✅ Simulation complete!"
end
