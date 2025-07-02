# frozen_string_literal: true

class ProgressController < ApplicationController
  def index
    # @results = results_by_user
    # @rfid_tags = results_by_tag
    @scores = scores_by_tag
  end

  def display
    @score = 0
    @username = nil

    tracking_event = TrackingEvent.find_by(id: params[:tracking_event_id])
    return render template: "progress/display-mr-mike", layout: "mr_mike" unless tracking_event

    rfid_tag = tracking_event.rfid_tag
    @username = rfid_tag.user&.username || rfid_tag.label
    @score = if rfid_tag.user
               ScoringService.get_score(user: rfid_tag.user) if rfid_tag.user
             else
               ScoringService.get_score_for_tag(tag: rfid_tag)
             end

    render template: "progress/display-mr-mike", layout: "mr_mike"
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
    ActiveRecord::Base.connection.execute(
      <<~SQL
        with scores as (
          select
            coalesce(rt.user_id, rt.id)    as id,
            coalesce(u.username, rt.label) as label,
            case
                when rt.user_id is not null then 'user'
                else 'tag'
            end as type,
            s.event_id,
            s.location_id,
            s.score_type,
            s.score_type,
            array_agg(s.score),
            case
                when s.score_type = 'scan_again' then sum(s.score)
                else min(s.score)
            end as score
          from scores s
              left outer join rfid_tags rt on rt.id = s.rfid_tag_id
              left outer join users u on u.id = rt.user_id
          group by 1, 2, 3, 4, 5, 6, 7
        )
        select
            id,
            label,
            type,
            sum(score)::integer as score,
            dense_rank() over (order by sum(score) desc) as rank
        from scores
        group by 1, 2, 3
        order by 4 desc
      SQL
    )
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
