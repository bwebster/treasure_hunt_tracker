desc "Clean tracking events and scores from DB"
task :clean => :environment do
  TrackingEvent.destroy_all
  Score.destroy_all
end
