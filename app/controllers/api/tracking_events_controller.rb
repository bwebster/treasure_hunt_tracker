# frozen_string_literal: true

module Api
  class TrackingEventsController < ApplicationController
    skip_before_action :verify_authenticity_token

    rescue_from StandardError, with: :handle_exception

    def create
      rfid_id = params[:rfid_id] || params[:id]
      submitted_location = params[:location] || params[:loc]
      scanned_at = params[:scanned_at] || params[:at] || Time.current
      metadata = params[:metadata]

      location = find_location(scanned_at, submitted_location)

      rfid_tag, tracking_event = create_tracking_event(rfid_id, submitted_location, scanned_at, metadata, location)

      ProcessTrackingEventJob.perform_later(tracking_event_id: tracking_event.id)
      broadcast_location_update(location, rfid_tag, tracking_event)

      render json: { success: true, tracking_event: tracking_event }, status: :created
    end

    private

    def create_tracking_event(rfid_id, submitted_location, scanned_at, metadata, location)
      rfid_tag = nil
      tracking_event = ActiveRecord::Base.transaction do
        rfid_tag = find_or_create_tag(rfid_id)

        rfid_tag.tracking_events.create!(
          submitted_location: submitted_location,
          scanned_at: scanned_at,
          metadata: metadata,
          location_id: location&.id
        )
      end
      [rfid_tag, tracking_event]
    end

    def broadcast_location_update(location, rfid_tag, tracking_event)
      return unless location

      if location.registration?
        ActionCable.server.broadcast(
          "register_channel",
          {
            rfid_id: rfid_tag.id,
            location_number: location.id,
            tracking_event_id: tracking_event.id
          }
        )
      elsif location.display?
        ActionCable.server.broadcast(
          "display_channel",
          {
            location_number: location.id,
            tracking_event_id: tracking_event.id
          }
        )
      end
    end

    def find_or_create_tag(rfid_id)
      RfidTag.find_or_create_by!(tag_id: rfid_id) do |tag|
        tag.label = RfidTag.generate_label
      end
    rescue ActiveRecord::RecordInvalid => e
      retry if "Label has already been taken".match?(e.message)
    end

    def find_location(scanned_at, submitted_location)
      Rails.logger.info "Finding location for submitted location id #{submitted_location} and date #{scanned_at}"

      event = Event.for_scan(scanned_at)
      Rails.logger.info "Event is #{event&.name} on #{event&.date}"
      return unless event

      location = event.locations.find_by(number: submitted_location)
      Rails.logger.info "Location is #{location&.number} - #{location&.name}"

      location
    end

    def handle_exception(exception)
      Rails.logger.error("TrackingEventsController error: #{exception.message} #{exception.backtrace.join("\n")}")
      render json: {
        error: exception.message,
        backtrace: exception.backtrace.take(10) # Return first 10 lines of the backtrace
      }, status: :internal_server_error
    end
  end
end
