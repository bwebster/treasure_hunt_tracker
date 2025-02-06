require 'rails_helper'

RSpec.describe "Api::TrackingEvents", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/api/tracking_events/create"
      expect(response).to have_http_status(:success)
    end
  end

end
