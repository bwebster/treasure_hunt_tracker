class TrackingEventsController < ApplicationController
  def index
    @tracking_events = TrackingEvent.left_joins(location: :event).order(scanned_at: :desc)
  end
end
