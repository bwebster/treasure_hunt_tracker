require 'net/http'
require 'json'
require 'securerandom'

# Configuration
API_ENDPOINT = "http://localhost:5000/api/tracking_events" # Change if needed
SIMULATED_EVENT_COUNT = 50 # Adjust the number of tracking events
DELAY_RANGE = 1..5 # Random delay between events (in seconds)

rfid_tags = Array.new(20) { SecureRandom.alphanumeric(6).upcase }

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
  rfid_tag = rfid_tags.sample # Pick a random RFID tag

  payload = {
    rfid_id: rfid_tag,
    location: location.name,
    scanned_at: event.date
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
