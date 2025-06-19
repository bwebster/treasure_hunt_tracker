# frozen_string_literal: true

class ScoringService

  TYPES = [
    TYPE_SCAN = :scan,
    TYPE_MULTIPLE_SCAN_BONUS = :multi_scan_bonus
  ].freeze

  SCORING = {
    TYPE_SCAN => Integer(ENV.fetch("SCORING_TYPE_SCAN", "10000")),
    TYPE_MULTIPLE_SCAN_BONUS => Integer(ENV.fetch("TYPE_MULTIPLE_SCAN_BONUS", "1000")) # multiplied by count of previous scan
  }.freeze

  def self.score(tracking_event:)
    new.score(tracking_event: tracking_event)
  end

  def score(tracking_event:)
    unless tracking_event.location
      Rails.logger.info "Skipping event - no location"
      return
    end

    if tracking_event.location&.registration?
      Rails.logger.info "Skipping event - registration event"
      return
    end

    # Try to get an advisory lock
    lock_key = Zlib.crc32("rfid:#{tracking_event.rfid_tag_id}")
    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT pg_advisory_lock(?)", lock_key])
    )

    begin
      scan_score = add_score_for_scan(tracking_event)
      add_score_if_previous_scan(tracking_event) if scan_score
    ensure
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT pg_advisory_unlock(?)", lock_key])
      )
    end
  end

  private

  def add_score_for_scan(tracking_event)
    if Score.where(tracking_event_id: tracking_event.id).any?
      Rails.logger.info "Skipping event - already scored"
      return
    end
    if Score.where(rfid_tag_id: tracking_event.rfid_tag_id, location_id: tracking_event.location_id).any?
      Rails.logger.info "Skipping event - score exists for tag and location"
      return
    end

    Score.find_or_create_by!(id: "#{tracking_event.id}-score") do |s|
      s.tracking_event_id = tracking_event.id
      s.event_id = tracking_event.location.event_id
      s.location_id =  tracking_event.location_id
      s.rfid_tag_id = tracking_event.rfid_tag_id

      s.score = SCORING.fetch(TYPE_SCAN)
      s.score_type = TYPE_SCAN

      loc = tracking_event.location.name
      time = tracking_event.scanned_at.in_time_zone("America/Chicago").strftime("%Y-%m-%d %H:%M:%S")
      s.source = "Scan at #{loc} on #{time}"
    end
  end

  def add_score_if_previous_scan(tracking_event)
    count = Score
              .where(
                rfid_tag_id: tracking_event.rfid_tag_id,
                event_id: tracking_event.location.event_id,
                score_type: TYPE_SCAN
              )
              .where.not(location_id: tracking_event.location_id)
              .count
    return if count.zero?

    Score.find_or_create_by!(id: "#{tracking_event.id}-prev-scan-bonus-#{count}") do |s|
      s.tracking_event_id = tracking_event.id
      s.event_id = tracking_event.location.event_id
      s.location_id =  tracking_event.location_id
      s.rfid_tag_id = tracking_event.rfid_tag_id

      multiplier = SCORING.fetch(TYPE_MULTIPLE_SCAN_BONUS)
      s.score = multiplier * count
      s.score_type = TYPE_MULTIPLE_SCAN_BONUS

      s.source = "Bonus: #{multiplier} * #{count} previous scans"
    end
  end
end
