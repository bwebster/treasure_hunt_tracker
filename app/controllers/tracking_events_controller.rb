class TrackingEventsController < AdminController
  def index
    @tracking_events = TrackingEvent
                         .left_joins(location: :event)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(30)
  end
end
