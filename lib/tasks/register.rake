desc "Simulate RFID registration event"
task register: :environment do
  date = ENV.fetch("DATE")
  location_number = ENV.fetch("LOCATION")

  event = Event.find_by(date: date)
  raise "No event found for date #{date}" unless event

  location = event.locations.find_by(number: location_number)
  rails "No location found for number #{location_number}" unless location

  rfid = RfidTag.all.sample(1).first
  puts "Registering RFID #{rfid.tag_id} (#{rfid.id}) at location #{location.number} (#{location.id})"

  ActionCable.server.broadcast("register_channel", { rfid_id: rfid.id, location_number: location.id })
end
