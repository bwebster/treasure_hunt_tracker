# frozen_string_literal: true

namespace :tracking_events do
  desc "Remove all scores and reprocess tracking events"
  task rescore: :environment do
    Rake::Task["clean:scores"].invoke
    Rake::Task["tracking_events:reprocess"].invoke
  end

  desc "Enqueue ProcessTrackingEventJob for all tracking events"
  task reprocess: :environment do
    puts "Enqueuing all ProcessTrackingEventJob to reprocess..."

    TrackingEvent.find_each do |event|
      ProcessTrackingEventJob.perform_later(tracking_event_id: event.id)
    end

    puts "✅ Successfully enqueued jobs for all tracking events!"
  end
end
