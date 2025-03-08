module LocationsHelper
  def unused_locations(event, location)
    taken = event.locations.map { |l| l.number if l != location }
    puts "Taken: #{taken}"
    (0..20).to_a - taken
  end
end
