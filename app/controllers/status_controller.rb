# frozen_string_literal: true

class StatusController < AdminController
  Status = Struct.new(:number, :location, :received, keyword_init: true)

  def index
    @status = []

    health_checks = HealthCheck
                    .group(:location)
                    .select(:location, "MAX(created_at) as received")
                    .order(location: :asc)

    today = Date.today.in_time_zone("America/Chicago")
    most_recent_event = Event.where("date <= ?", today).order(date: :desc).first
    return unless most_recent_event

    current_locations = most_recent_event.locations.index_by { |loc| loc.number.to_s }

    @status = health_checks.collect do |health_check|
      Status.new(
        number: health_check.location,
        location: current_locations[health_check.location],
        received: health_check.received
      )
    end

    @location_status = current_locations.values.collect do |location|
      Status.new(
        location: location,
        received: health_checks
                    .detect { |hc| hc.location == location.number.to_s }
                    &.received
      )
    end.sort_by { |status| status.location.name }
  end
end
