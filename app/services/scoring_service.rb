# frozen_string_literal: true

class ScoringService

  TYPES = [
    TYPE_SCAN = :scan,
    TYPE_MULTIPLE_SCAN_BONUS = :multi_scan_bonus
  ].freeze

  SCORING = {
    TYPE_SCAN => 10_000,
    TYPE_MULTIPLE_SCAN_BONUS => 5_000 # per previous scan
  }.freeze

  def self.score(tracking_event:)
    new.score(tracking_event: tracking_event)
  end

  def score(tracking_event:)
    scan_score = add_score_for_scan(tracking_event)
    add_score_if_previous_scan(tracking_event, scan_score)
  end

  private

  def debug
    puts "*************SCORE*********************"
    yield
    puts "***************************************"
  end

  def add_score_for_scan(tracking_event)
    Score.find_or_create_by!(id: "#{tracking_event.id}-score") do |s|
      s.rfid_tag_id = tracking_event.rfid_tag_id
      s.score = SCORING.fetch(TYPE_SCAN)
      s.score_type = TYPE_SCAN

      debug do
        puts "[#{s.score_type}] id=#{s.id} rfid=#{s.rfid_tag_id} score=#{s.score}"
      end
    end
  end

  def add_score_if_previous_scan(tracking_event, scan_score)
    # find count of previous tracking events for this tag
    count = TrackingEvent.
      joins(location: :event).
      where(rfid_tag_id: tracking_event.rfid_tag_id).
      where.not(location_id: tracking_event.location_id).
      where("events.id = ?", tracking_event.location.event_id).
      count

    debug do
      puts "Count of previous events for rfid=#{tracking_event.rfid_tag_id} event=#{tracking_event.location.event_id} is #{count}a"
    end

    # count = Score.for_tag_id(tracking_event.rfid_tag_id).where(score_type: TYPE_SCAN).where.not(id: scan_score.id).count
    Rails.logger.info "Found #{count} previous tracking events for #{tracking_event.rfid_tag_id}"
    return if count.zero?

    multiplier = SCORING.fetch(TYPE_MULTIPLE_SCAN_BONUS)
    Rails.logger.info "Adding bonus #{multiplier} * #{count} for #{tracking_event.rfid_tag_id}"

    Score.find_or_create_by!(id: "#{tracking_event.id}-prev-scan-bonus-#{count}") do |s|
      s.rfid_tag_id = tracking_event.rfid_tag_id
      s.score = multiplier * count
      s.score_type = TYPE_MULTIPLE_SCAN_BONUS
      debug do
        puts "[#{s.score_type}] id=#{s.id} rfid=#{s.rfid_tag_id} score=#{s.score}"
      end
    end
  end
end
