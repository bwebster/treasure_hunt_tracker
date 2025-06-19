# frozen_string_literal: true

require "net/http"
require "json"
require "securerandom"

API_ENDPOINT = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                 "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/tracking_events"
               else
                 "http://localhost:3000/api/tracking_events"
               end
DELAY_RANGE = 1..5 # Random delay between events (in seconds)

namespace :simulate do
  desc "Simulate a series of tracking events for a single tag"
  task one: :environment do
    rfid_tag_id = ENV.fetch("RFID") { RfidTag.all.sample.tag_id }

    # Fetch all available events with locations
    events = Event.includes(:locations).where.not(locations: { id: nil }).order(date: :asc).to_a
    if events.empty?
      puts "No events with locations found. Exiting."
      exit
    end

    puts "Starting simulation of tracking events..."

    events.each do |event|
      event.locations.order(id: :asc).each do |location|
        next if location.registration?

        payload = {
          id: rfid_tag_id,
          loc: location.number,
          at: event.date
        }

        # Send the HTTP POST request to create a tracking event
        uri = URI(API_ENDPOINT)
        response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")

        if response.code == "201"
          puts "✔ Event: RFID #{rfid_tag_id} scanned at #{location.name} (#{event.name}) at #{event.date}"
        else
          puts "❌ Event failed: #{response.body}"
        end

        # Wait for a random amount of time before the next request
        sleep(rand(DELAY_RANGE))
      end
    end

    puts "✅ Simulation complete!"
  end

  desc "Simulate multiple tracking events for multiple tags"
  task many: :environment do
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
      location = event.locations.sample while location.registration?
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
end
