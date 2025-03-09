desc "Simulate RFID registration event"
task register: :environment do
  date = ENV.fetch("DATE") { Event.order(date: :asc).first.date }
  event = Event.where(date: date).first
  raise "No event found for date #{date}" unless event

  location_number = ENV.fetch("LOCATION") { event.locations.where(registration: true).first.number }
  location = Location.find_by(number: location_number)
  raise "No location found for number #{location_number}" unless location

  rfid = RfidTag.all.sample(1).first
  puts "Registering RFID #{rfid.tag_id} (#{rfid.id}) at location #{location.number} (#{location.id})"

  ActionCable.server.broadcast("register_channel", { rfid_id: rfid.id, location_number: location.id })
end
