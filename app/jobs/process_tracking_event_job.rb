class ProcessTrackingEventJob < ApplicationJob
  queue_as :default

  def perform(tracking_event_id:)
    tracking_event = TrackingEvent.find(tracking_event_id)

    Rails.logger.info "Mapping to location"
    Rails.logger.info "Submitted location is #{tracking_event.submitted_location}"
    Rails.logger.info "Scanned at #{tracking_event.scanned_at}"

    event = Event.find_by(date: tracking_event.scanned_at.to_date)
    Rails.logger.info "Event is #{event&.id}"

    if event
      location = event.locations.find_by(name: tracking_event.submitted_location)
      Rails.logger.info "Location is #{location&.name}"

      if location
        tracking_event.update(location_id: location.id)
      end
    end

    Rails.logger.info "Processing tracking event #{tracking_event_id}"
  end
end
