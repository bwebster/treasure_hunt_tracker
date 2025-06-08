namespace :clean do
  desc "Clean all tracking events and scores from DB"
  task :all => :environment do
    TrackingEvent.destroy_all
    Score.destroy_all
  end

  desc "Clean scores from DB"
  task :scores => :environment do
    Score.destroy_all
  end
end
