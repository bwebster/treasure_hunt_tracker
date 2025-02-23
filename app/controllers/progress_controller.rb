class ProgressController < ApplicationController
  def index
    @results = results_by_user
    @rfid_tags = results_by_tag
    @scores = scores_by_tag
  end

  private

  def results_by_tag
    RfidTag
      .select(
        "rfid_tags.*,
        COUNT(DISTINCT tracking_events.location_id) AS scanned_locations,
        (SELECT COUNT(*) FROM locations) AS total_locations,
        (COUNT(DISTINCT tracking_events.location_id) * 100.0) / NULLIF((SELECT COUNT(*) FROM locations), 0) AS completion_percentage"
      )
      .joins(:tracking_events)
      .group("rfid_tags.id")
      .order("completion_percentage DESC NULLS LAST")
  end

  def scores_by_tag
    Score.select("
        rfid_tag_id,
        sum(score) as score,
        dense_rank() over (order by sum(score) desc) as rank
    ")
      .includes(:rfid_tag)
      .group("rfid_tag_id")
      .order("score desc")
  end

  def results_by_user
    User
      .select(
        "users.*,
        COUNT(DISTINCT tracking_events.location_id) AS scanned_locations,
        (SELECT COUNT(*) FROM locations) AS total_locations,
        (COUNT(DISTINCT tracking_events.location_id) * 100.0) / NULLIF((SELECT COUNT(*) FROM locations), 0) AS completion_percentage"
      )
      .joins(rfid_tags: { tracking_events: :location })
      .group("users.id")
      .order("completion_percentage DESC NULLS LAST")
  end
end
