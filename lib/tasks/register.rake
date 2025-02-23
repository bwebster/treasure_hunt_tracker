desc "Simulate RFID registration event"
task :register, [:location_number] => :environment do |_, args|
  location_number = args[:location_number] || 0

  rfid_id = SecureRandom.hex(3).upcase # Generate a random RFID ID
  puts "Registering RFID Tag #{rfid_id} at location #{location_number}"

  # Broadcast event to WebSockets
  ActionCable.server.broadcast("register_channel", { rfid_id: RfidTag.all.sample(1).first.id, location_number: location_number })
end
