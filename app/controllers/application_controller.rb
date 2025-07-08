# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def admin
    @unique_tag_count = unique_tag_count
    @unique_user_count = unique_user_count
    @scan_count = scan_count
    @multi_sunday_users = multi_sunday_users
  end

  private

  def unique_tag_count
    RfidTag.all.count
  end

  def unique_user_count
    User.all.count
  end

  def scan_count
    TrackingEvent.all.count
  end

  def multi_sunday_users
    data = ActiveRecord::Base.connection.execute(
      <<~SQL
        with data as (
          select
            coalesce(u.username, rt.label) as username,
            count(distinct(case when e.test_event then NULL else e.name end)) as count
          from scores s
          left join events e on e.id = s.event_id
          left outer join rfid_tags rt on rt.id = s.rfid_tag_id
          left outer join users u on u.id = rt.user_id
          group by 1
        )
        select count(*) as count
        from data
        where count > 1
      SQL
    )
    data&.first&.[]("count") || 0
  end
end
