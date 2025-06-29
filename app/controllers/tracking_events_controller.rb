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

  def activity
    # List of dates with tracking data
    @available_days = TrackingEvent
                      .distinct
                      .pluck("DATE(scanned_at)")
                      .sort

    @selected_day = params[:day]&.to_date || @available_days.last

    # Aggregate scans by location and 10-minute buckets
    time_bucket = "date_trunc('hour', scanned_at) + (date_part('minute', scanned_at)::int / 10) * interval '10 minutes'"
    @scan_data = TrackingEvent
                 .where(scanned_at: @selected_day.all_day)
                 .group(Arel.sql("location_id"), Arel.sql(time_bucket))
                 .order(Arel.sql("location_id"), Arel.sql(time_bucket))
                 .count

    @locations = Location.where(id: @scan_data.keys.map(&:first).uniq).index_by(&:id)

    # Precompute full timeline
    time_buckets = (0..143).map { |i| @selected_day.beginning_of_day + i * 10.minutes }

    # Map: { location_id => { "HH:MM" => count } }
    @chart_data = @scan_data
                  .group_by { |(location_id, _time), _count| location_id }
                  .transform_values do |entries|
      raw = entries.to_h { |((_loc_id, ts), count)| [ts.strftime("%H:%M"), count] }

      # Fill in missing time slots with 0
      time_buckets.to_h do |ts|
        time_str = ts.strftime("%H:%M")
        [time_str, raw[time_str] || 0]
      end
    end
  end
end
