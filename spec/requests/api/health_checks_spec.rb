# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::HealthChecks", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  describe "GET /api/health_checks" do
    it "returns a 200 status" do
      location = FactoryBot.create(:location)

      params = {
        l: location.number.to_s
      }
      expect do
        get "/api/health_checks", params:, headers:
      end.to change(HealthCheck, :count).by(1)

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["ok"]).to eq(true)

      expect(HealthCheck.last).to have_attributes(location: location.number.to_s)
    end
  end
end
