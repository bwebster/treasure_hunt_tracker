module ProgressHelper
  class Level
    attr_accessor :level, :title
    def initialize(level, title)
      @level = level
      @title = title
    end
  end

  def leveling(score)
    if score >= 100_000
      Level.new("L-6", "Galactic Hero")
    elsif score >= 75_000
      Level.new("L-5", "Cosmic Commander")
    elsif score >= 50_000
      Level.new("L-4", "Ranger 1st Class")
    elsif score >= 25_000
      Level.new("L-3", "Planetary Pilot")
    elsif score >= 1_000
      Level.new("L-2", "Space Rookie")
    else
      Level.new("L-1", "Star Cadet")
    end
  end
end
