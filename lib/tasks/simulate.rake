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

    # If date is provided, fetch event for date
    # Otherwise, fetch all available events with locations
    date = ENV["DATE"]
    events = if date
               Event.where(date:).to_a
             else
               Event.includes(:locations).where.not(locations: { id: nil }).to_a
             end
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
      if location.display? && location.registration?
        sleep(7)
      else
        sleep(rand(delay_range))
      end
    end

    puts "✅ Simulation complete!"
  end

  desc "Simulate a single display location scan"
  task display_scan: :environment do
    api_endpoint = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                     "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/tracking_events"
                   else
                     "http://localhost:3000/api/tracking_events"
                   end

    rfid_tag_id = ENV.fetch("RFID") { RfidTag.all.sample.tag_id }

    date = ENV.fetch("DATE") { Time.zone.now.in_time_zone("America/Chicago").to_date }
    event = Event.find_by(date:)
    event ||= Event.order(date: :asc).first
    raise "No event found for date #{date}" unless event

    puts "Found event: #{event.name} on #{event.date}"

    location = Location.for_event(event).where(display: true).sample
    event = location.event
    unless location
      puts "No display location found. Exiting."
      return
    end

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
      puts "✔ Event: RFID #{rfid_tag_id} scanned at #{location.name} (#{location.id}) for event #{event.name} on #{event.date}"
    else
      puts "❌ Event failed: #{response.body}"
    end

    puts "✅ Simulation complete!"
  end

  desc "Simulate health checks for all known locations and one unknown"
  task health_checks: :environment do
    api_endpoint = if ENV.key?("HEROKU_APP_DEFAULT_DOMAIN_NAME")
                     "https://#{ENV['HEROKU_APP_DEFAULT_DOMAIN_NAME']}/api/health_checks"
                   else
                     "http://localhost:3000/api/health_checks"
                   end

    location_numbers = Location.distinct(:number).pluck(:number)

    # add one unknown location
    1.upto(20).each do |i|
      next if location_numbers.include?(i)

      location_numbers << i
      break
    end

    location_numbers.each do |loc|
      uri = URI(api_endpoint)
      uri.query = "l=#{loc}"
      body = Net::HTTP.get(uri, "Content-Type" => "application/json")

      if body && body["ok"]
        puts "✔ Health Check send for location #{loc}"
      else
        puts "❌ Health Check failed: #{response.body}"
      end
    end

    puts "✅ Simulation complete!"
  end
end
