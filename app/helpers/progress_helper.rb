# frozen_string_literal: true

module ProgressHelper
  def leveling(score)
    Level.for_score(score)
  end
end
