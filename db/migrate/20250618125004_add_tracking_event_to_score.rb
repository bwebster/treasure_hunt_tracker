# frozen_string_literal: true

class AddTrackingEventToScore < ActiveRecord::Migration[8.0]
  def change
    add_reference :scores, :tracking_event, type: :uuid, foreign_key: true
  end
end
