# frozen_string_literal: true

class ReportsController < AdminController
  SCANS_PER_USER = "scans-per-user"

  Report = Struct.new(:name, :data, :key, keyword_init: true)

  def index; end

  def show
    case params[:id]
    when SCANS_PER_USER
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
          count(distinct(e.name)) as event_count,
          count(*) as total_count
        from scores s
        left join events e on e.id = s.event_id
        left outer join rfid_tags rt on rt.id = s.rfid_tag_id
        left outer join users u on u.id = rt.user_id
        group by 1, 2, 3
        order by 4 desc, 5 desc, 1 desc
      SQL
    ).tap do |v|
      Rails.logger.info "Report results: #{v.inspect}"
    end

    Report.new(
      name: "Events Scanned per User",
      data:,
      key: SCANS_PER_USER
    )
  end
end
