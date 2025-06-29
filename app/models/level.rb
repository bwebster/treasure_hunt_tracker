# frozen_string_literal: true

class Level
  attr_reader :level, :title

  def initialize(level, title)
    @level = level
    @title = title
  end

  def self.for_score(score)
    score = Integer(score)
    levels = [
      [200_000, "L-11", "Infinity Legend 🌟"],
      [180_000, "L-10", "Gamma Sector Commander"],
      [160_000, "L-9",  "Star Cruiser Ace"],
      [140_000, "L-8",  "Galactic Hero"],
      [120_000, "L-7",  "Mission Pilot"],
      [100_000, "L-6",  "Lunar Lander"],
      [80_000,  "L-5",  "Astro Scout"],
      [60_000,  "L-4",  "Orbital Operator"],
      [40_000,  "L-3",  "Comet Chaser"],
      [20_000,  "L-2",  "Rocket Recruit"],
      [0,       "L-1",  "Star Cadet"]
    ]

    level = levels.find { |min_score, _, _| score >= min_score }
    Level.new(level[1], level[2])
  end
end
