# frozen_string_literal: true

module Api
  class TrackingEventsController < ApplicationController
    skip_before_action :verify_authenticity_token

    rescue_from StandardError, with: :handle_exception

    def create
      rfid_id = params[:rfid_id] || params[:id]
      location = params[:location] || params[:loc]
      scanned_at = params[:scanned_at] || params[:at] || Time.current
      metadata = params[:metadata]

      rfid_tag = nil
      tracking_event = ActiveRecord::Base.transaction do
        begin
          rfid_tag = RfidTag.find_or_create_by!(tag_id: rfid_id) do |tag|
            tag.label = RfidTag.generate_label
          end
        rescue ActiveRecord::RecordInvalid => e
          retry if "Label has already been taken".match?(e.message)
        end

        rfid_tag.tracking_events.create!(
          submitted_location: location,
          scanned_at: scanned_at,
          metadata: metadata
        )
      end

      location = find_location(location, scanned_at)
      if location&.registration?
        ActionCable.server.broadcast("register_channel", {
                                       rfid_id: rfid_tag.id,
                                       location_number: location.id,
                                       tracking_event_id: tracking_event.id
                                     })
      else
        ProcessTrackingEventJob.perform_later(tracking_event_id: tracking_event.id)
      end

      render json: { success: true, tracking_event: tracking_event }, status: :created
    end

    private

    def find_location(location, scanned_at)
      scanned_at = scanned_at.in_time_zone("America/Chicago").to_date
      event = Event.find_by(date: scanned_at)
      return unless event

      event.locations.find_by(number: location)
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
