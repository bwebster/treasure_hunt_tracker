# frozen_string_literal: true

class TrackingEventsController < AdminController
  PAGE_SIZE = ENV.fetch("TRACKING_EVENTS_PER_PAGE", 30).to_i

  def index
    @tracking_events = TrackingEvent
                       .includes(:rfid_tag, :user)
                       .left_joins(location: :event)
                       .order(**sorting(:scanned_at, :desc))
                       .page(params[:page])
                       .per(PAGE_SIZE)
  end
end
