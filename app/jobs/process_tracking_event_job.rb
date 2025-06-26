# frozen_string_literal: true

class ProcessTrackingEventJob < ApplicationJob
  queue_as :default

  def perform(tracking_event_id:)
    tracking_event = TrackingEvent.find(tracking_event_id)

    map_to_event_and_location(tracking_event)
    insert_score(tracking_event)

    Rails.logger.info "Processing tracking event #{tracking_event_id}"
  end

  private

  def insert_score(tracking_event)
    ScoringService.score(tracking_event: tracking_event)
  end

  def map_to_event_and_location(tracking_event)
    Rails.logger.info "Mapping to location"
    Rails.logger.info "Submitted location is #{tracking_event.submitted_location}"

    scanned_at = tracking_event.scanned_at.in_time_zone("America/Chicago")
    Rails.logger.info "Scanned at #{tracking_event.scanned_at} (#{scanned_at.to_date})"

    event = Event.find_by(date: scanned_at.to_date)
    Rails.logger.info "Event is #{event&.id}"
    return unless event

    location = event.locations.find_by(number: tracking_event.submitted_location)
    Rails.logger.info "Location is #{location&.name}"

    return unless location

    tracking_event.update(location_id: location.id)
  end
end
