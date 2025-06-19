# frozen_string_literal: true

class ScoresController < AdminController
  PAGE_SIZE = ENV.fetch("SCORES_PER_PAGE", 30).to_i

  def index
    @scores = Score
              .joins(:tracking_event)
              .includes(:rfid_tag, :location, :event, :tracking_event)
              .order(**sorting("tracking_event.scanned_at", "desc"))
              .page(params[:page])
              .per(PAGE_SIZE)
  end
end
