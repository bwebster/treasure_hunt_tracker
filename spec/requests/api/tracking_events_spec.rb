# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::TrackingEvents", type: :request do
  describe "POST /api/tracking_events" do
    it "returns http success" do
      headers = { "CONTENT_TYPE" => "application/json" }
      payload = {
        "id" => "abc123",
        "loc" => "3"
      }

      expect do
        post "/api/tracking_events", params: payload.to_json, headers: headers
      end.to change(TrackingEvent, :count).by(1)

      expect(response).to have_http_status(:success)
    end
  end
end
