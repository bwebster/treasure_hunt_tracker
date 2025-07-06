# frozen_string_literal: true

class ScoringService
  TYPES = [
    TYPE_SCAN = "scan",
    TYPE_SCAN_AGAIN = "scan_again",
    TYPE_MULTIPLE_SCAN_BONUS = "multi_scan_bonus",
    TYPE_SCAN_MULTI_EVENT_BONUS = "multi_event_bonus"
  ].freeze

  SCORING = {
    TYPE_SCAN => Integer(ENV.fetch("SCORING_TYPE_SCAN", "10000")),
    TYPE_SCAN_AGAIN => Integer(ENV.fetch("SCORING_TYPE_SCAN", "100")),
    TYPE_MULTIPLE_SCAN_BONUS => Integer(ENV.fetch("TYPE_MULTIPLE_SCAN_BONUS", "1000")), # multiplied by count of previous scan
    TYPE_SCAN_MULTI_EVENT_BONUS => Integer(ENV.fetch("TYPE_SCAN_MULTI_EVENT_BONUS", "25000"))
  }.freeze

  def self.get_score(user:)
    ids = user.rfid_tags.map(&:id)
    Score.where(rfid_tag_id: ids).sum(:score)
  end

  def self.get_score_for_tag(tag:)
    Score.where(rfid_tag_id: tag.id).sum(:score)
  end

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
      if scan_score && scan_score.score_type == TYPE_SCAN && scan_score.score.positive?
        add_score_if_previous_scan(tracking_event)
        add_score_for_multiple_events(tracking_event)
      end
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
    prev_count = Score.where(rfid_tag_id: tracking_event.rfid_tag_id, location_id: tracking_event.location_id).count

    Score.find_or_create_by!(id: "#{tracking_event.id}-score") do |s|
      s.tracking_event_id = tracking_event.id
      s.event_id = tracking_event.location.event_id
      s.location_id = tracking_event.location_id
      s.rfid_tag_id = tracking_event.rfid_tag_id

      type = prev_count.zero? ? TYPE_SCAN : TYPE_SCAN_AGAIN
      s.score_type = type
      s.score = if tracking_event.location.event.test_event?
                  0
                else
                  SCORING.fetch(type)
                end

      loc = tracking_event.location.name
      time = tracking_event.scanned_at.in_time_zone("America/Chicago").strftime("%Y-%m-%d %H:%M:%S")
      s.source = "Scan at #{loc} on #{time}"
    end
  end

  def add_score_for_multiple_events(tracking_event)
    prev_event_ids = Event.where(test_event: false).where("date < ?", tracking_event.location.event.date).pluck(:id)
    tag_ids = [tracking_event.rfid_tag_id]
    tag_ids += tracking_event.rfid_tag.user.rfid_tags.map(&:id) if tracking_event.rfid_tag.user

    prev_count = Score
                 .where(
                   rfid_tag_id: tag_ids,
                   event_id: prev_event_ids,
                   score_type: TYPE_SCAN
                 )
                 .count
    return unless prev_count.positive?

    Score.find_or_create_by!(id: "#{tracking_event.location.event.id}-multi-event-scan") do |s|
      s.tracking_event_id = tracking_event.id
      s.event_id = tracking_event.location.event_id
      s.location_id = tracking_event.location_id
      s.rfid_tag_id = tracking_event.rfid_tag_id

      score = SCORING.fetch(TYPE_SCAN_MULTI_EVENT_BONUS)
      s.score = score
      s.score_type = TYPE_SCAN_MULTI_EVENT_BONUS

      s.source = "Bonus: multiple events"
    end
  end

  def add_score_if_previous_scan(tracking_event)
    count = previous_score_count(tracking_event)
    return if count.zero?

    Score.find_or_create_by!(id: "#{tracking_event.id}-prev-scan-bonus-#{count}") do |s|
      s.tracking_event_id = tracking_event.id
      s.event_id = tracking_event.location.event_id
      s.location_id = tracking_event.location_id
      s.rfid_tag_id = tracking_event.rfid_tag_id

      multiplier = SCORING.fetch(TYPE_MULTIPLE_SCAN_BONUS)
      s.score = multiplier * count
      s.score_type = TYPE_MULTIPLE_SCAN_BONUS

      s.source = "Bonus: #{multiplier} * #{count} previous scans"
    end
  end

  private

  def previous_score_count(tracking_event)
    Score
      .where(
        rfid_tag_id: tracking_event.rfid_tag_id,
        event_id: tracking_event.location.event_id,
        score_type: TYPE_SCAN
      )
      .where.not(location_id: tracking_event.location_id)
      .count
  end
end
