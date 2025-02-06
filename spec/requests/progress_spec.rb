require 'rails_helper'

RSpec.describe "Progresses", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/progress/index"
      expect(response).to have_http_status(:success)
    end
  end

end
