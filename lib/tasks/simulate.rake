# frozen_string_literal: true

require "net/http"
require "json"
require "securerandom"

namespace :simulate do
  desc "Simulate having a ton of users"
  task many_users: :environment do
    require "faker"

    count = Integer(ENV.fetch("COUNT", "300"))

    Rails.logger.info "Creating #{count} users"
    count.times do
      User.create!(username: Faker::Name.name)
    end
  end

  desc "Simulate a series of tracking events for a single tag"
  task one: :environment do
    api_endpoint = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                     "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/tracking_events"
                   else
                     "http://localhost:3000/api/tracking_events"
                   end
    delay_range = 1..5 # Random delay between events (in seconds)

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

        at = event.date.in_time_zone("America/Chicago").to_time # Date in local timezone
        at += 9.upto(12).to_a.sample.hours

        payload = {
          id: rfid_tag_id,
          loc: location.number,
          at: at
        }

        # Send the HTTP POST request to create a tracking event
        uri = URI(api_endpoint)
        response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")

        if response.code == "201"
          puts "✔ Event: RFID #{rfid_tag_id} scanned at #{location.name} (#{event.name}) at #{event.date}"
        else
          puts "❌ Event failed: #{response.body}"
        end

        # Wait for a random amount of time before the next request
        sleep(rand(delay_range))
      end
    end

    puts "✅ Simulation complete!"
  end

  desc "Simulate multiple tracking events for multiple tags"
  task many: :environment do
    api_endpoint = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                     "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/tracking_events"
                   else
                     "http://localhost:3000/api/tracking_events"
                   end
    simulated_event_count = Integer(ENV.fetch("COUNT", "20"))
    delay_range = 1..5 # Random delay between events (in seconds)

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

    puts "Starting simulation of #{simulated_event_count} tracking events..."

    simulated_event_count.times do |i|
      event = events.sample # Pick a random event
      location = event.locations.sample # Pick a random location from the event
      location = event.locations.sample while location.registration?
      rfid_tag = rfid_tags.sample # Pick a random RFID tag

      at = event.date.in_time_zone("America/Chicago").to_time # Date in local timezone
      at += 9.upto(12).to_a.sample.hours

      payload = {
        id: rfid_tag,
        loc: location.number,
        at: at
      }

      # Send the HTTP POST request to create a tracking event
      uri = URI(api_endpoint)
      response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")

      if response.code == "201"
        puts "✔ Event #{i + 1}: RFID #{rfid_tag} scanned at #{location.name} (#{event.name}) at #{event.date}"
      else
        puts "❌ Event #{i + 1} failed: #{response.body}"
      end

      # Wait for a random amount of time before the next request
      sleep(rand(delay_range))
    end

    puts "✅ Simulation complete!"
  end
end
