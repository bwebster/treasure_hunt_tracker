class Api::TrackingEventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from StandardError, with: :handle_exception

  def create
    rfid_id = params[:rfid_id] || params[:id]
    location = params[:location] || params[:loc]
    scanned_at = params[:scanned_at] || params[:at] || Time.current
    metadata = params[:metadata]

    rfid_tag = nil
    tracking_event = ActiveRecord::Base.transaction do
      rfid_tag = RfidTag.find_or_create_by!(tag_id: rfid_id) do |tag|
        tag.label = RfidTag.generate_label
      end

      unless location.zero?
        rfid_tag.tracking_events.create!(
          submitted_location: location,
          scanned_at: scanned_at,
          metadata: metadata
        )
      end
    end

    if location.zero?
      ActionCable.server.broadcast("register_channel", { rfid_id: rfid_tag.id, location_number: location })
    else
      ProcessTrackingEventJob.perform_later(tracking_event_id: tracking_event.id)
    end

    render json: { success: true, tracking_event: tracking_event }, status: :created
  end

  private

  def handle_exception(exception)
    render json: {
      error: exception.message,
      backtrace: exception.backtrace.take(10) # Return first 10 lines of the backtrace
    }, status: :internal_server_error
  end
end
