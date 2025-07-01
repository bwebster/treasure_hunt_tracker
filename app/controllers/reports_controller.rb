# frozen_string_literal: true

class ReportsController < AdminController
  EVENTS_SCANNED_PER_USER = "events-scanned-per-user"

  Report = Struct.new(:name, :data, :key, keyword_init: true)

  def index; end

  def show
    case params[:id]
    when EVENTS_SCANNED_PER_USER
      @report = events_scanned_per_user
    else
      flash.now[:error] = "Report #{params[:id]} not found"
    end
  end

  private

  def events_scanned_per_user
    data = ActiveRecord::Base.connection.execute(
      <<~SQL
        select
          coalesce(rt.user_id, rt.id) as id,
          coalesce(u.username, rt.label) as username,
          case
              when rt.user_id is not null then 'user'
              else 'tag'
          end as type,
          count(e.name) as count
        from scores s
        left join events e on e.id = s.event_id
        left outer join rfid_tags rt on rt.id = s.rfid_tag_id
        left outer join users u on u.id = rt.user_id
        group by 1, 2, 3
        order by 4 desc
      SQL
    ).tap do |v|
      Rails.logger.info "Report results: #{v.inspect}"
    end

    Report.new(
      name: "Events Scanned per User",
      data:,
      key: EVENTS_SCANNED_PER_USER
    )
  end
end
