# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::TrackingEvents", type: :request do
  describe "POST /api/tracking_events" do
    it "returns http success" do
      allow(ProcessTrackingEventJob).to receive(:perform_later)

      headers = { "CONTENT_TYPE" => "application/json" }
      payload = {
        "id" => "abc123",
        "loc" => "3"
      }

      expect do
        post "/api/tracking_events", params: payload.to_json, headers: headers
      end.to change(TrackingEvent, :count).by(1).and change(RfidTag, :count).by(1)

      expect(response).to have_http_status(:success)

      tracking_event = TrackingEvent.last
      expect(tracking_event).to have_attributes(
        scanned_at: be_within(1.second).of(Time.zone.now),
        submitted_location: eq("3"),
        location_id: be_nil,
        rfid_tag: have_attributes(
          tag_id: "abc123"
        )
      )

      expect(ProcessTrackingEventJob)
        .to have_received(:perform_later)
        .once
        .with(tracking_event_id: tracking_event.id)
    end
  end
end
