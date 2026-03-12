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
    time_zone = "America/Chicago"

    @available_days = fetch_available_days
    @selected_day = params[:day]&.to_date || @available_days.last

    return if @selected_day.blank?

    @locations, @chart_data = fetch_activity_data(time_zone)
  end

  private

  def fetch_available_days
    time_zone = "America/Chicago"
    TrackingEvent
      .where.not(scanned_at: nil)
      .distinct
      .pluck(Arel.sql("DATE(scanned_at AT TIME ZONE 'UTC' AT TIME ZONE '#{time_zone}')"))
      .sort
  end

  def fetch_activity_data(time_zone)
    local_day_start = @selected_day.in_time_zone(time_zone).beginning_of_day
    time_buckets = (0..143).map { |i| local_day_start + i * 10.minutes }

    time_zone_sql = "scanned_at AT TIME ZONE 'UTC' AT TIME ZONE '#{time_zone}'"
    time_bucket_sql = <<~SQL.squish
      date_trunc('hour', #{time_zone_sql}) +
      floor(date_part('minute', #{time_zone_sql}) / 10) * interval '10 minutes'
    SQL

    raw_data = TrackingEvent
               .where("scanned_at >= ? AND scanned_at < ?", @selected_day.beginning_of_day, @selected_day.end_of_day)
               .group(Arel.sql("location_id"), Arel.sql(time_bucket_sql))
               .order(Arel.sql("location_id"), Arel.sql(time_bucket_sql))
               .count

    location_ids = raw_data.keys.map(&:first).uniq
    locations = Location.where(id: location_ids).index_by(&:id)

    chart_data = raw_data
                 .group_by { |(location_id, _), _| location_id }
                 .transform_values do |entries|
      raw = entries.to_h { |((_loc_id, ts), count)| [ts.strftime("%H:%M"), count] }

      time_buckets.to_h do |ts|
        time_str = ts.strftime("%H:%M")
        [time_str, raw[time_str] || 0]
      end
    end

    [locations, chart_data]
  end
end
