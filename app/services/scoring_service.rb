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
    lock_key = Zlib.crc32("rfid:#{tracking_event.rfid_tag_id}")

    # Try to get an advisory lock
    ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(#{lock_key})")

    begin
      unless tracking_event.location
        puts "Skipping event - no location"
        return
      end

      if tracking_event.location&.registration?
        puts "Skipping event - registration event"
        return
      end

      scan_score = add_score_for_scan(tracking_event)
      if scan_score
        add_score_if_previous_scan(tracking_event, scan_score)
      end
    ensure
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{lock_key})")
    end
  end

  private

  def debug
    puts "*************SCORE*********************"
    yield
    puts "***************************************"
  end

  def add_score_for_scan(tracking_event)
    if Score.where(tracking_event_id: tracking_event.id).any?
      puts "Skipping event - already scored"
      return
    end
    if Score.where(rfid_tag_id: tracking_event.rfid_tag_id, location_id: tracking_event.location_id).any?
      puts "Skipping event - score exists for tag and location"
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

      debug do
        puts "[#{s.score_type}] id=#{s.id} rfid=#{s.rfid_tag_id} score=#{s.score}"
      end
    end
  end

  def add_score_if_previous_scan(tracking_event, scan_score)
    # count = 0
    # event = tracking_event.location.event
    # event.locations.each do |loc|
    #   next if loc.id == tracking_event.location.id
    #
    #   count += 1 if TrackingEvent.for_tracking_event(tracking_event).for_location(loc).exists?
    # end
    count = Score
              .where(
                rfid_tag_id: tracking_event.rfid_tag_id,
                event_id: tracking_event.location.event_id,
                score_type: TYPE_SCAN
              )
              .where.not(location_id: tracking_event.location_id)
              .count

    # # find count of previous tracking events for this tag
    # count = TrackingEvent.
    #   joins(location: :event).
    #   where(rfid_tag_id: tracking_event.rfid_tag_id).
    #   where.not(location_id: tracking_event.location_id).
    #   where("events.id = ?", tracking_event.location.event_id).
    #   count

    debug do
      puts "Count of previous events for rfid=#{tracking_event.rfid_tag_id} event=#{tracking_event.location.event_id} is #{count}"
    end

    Rails.logger.info "Found #{count} previous tracking events for #{tracking_event.rfid_tag_id}"
    return if count.zero?

    multiplier = SCORING.fetch(TYPE_MULTIPLE_SCAN_BONUS)
    Rails.logger.info "Adding bonus #{multiplier} * #{count} for #{tracking_event.rfid_tag_id}"

    Score.find_or_create_by!(id: "#{tracking_event.id}-prev-scan-bonus-#{count}") do |s|
      s.tracking_event_id = tracking_event.id
      s.event_id = tracking_event.location.event_id
      s.location_id =  tracking_event.location_id
      s.rfid_tag_id = tracking_event.rfid_tag_id

      s.score = multiplier * count
      s.score_type = TYPE_MULTIPLE_SCAN_BONUS
      s.source = "Bonus - #{multiplier} * #{count} previous scans"

      debug do
        puts "[#{s.score_type}] id=#{s.id} rfid=#{s.rfid_tag_id} score=#{s.score}"
      end
    end
  end
end
