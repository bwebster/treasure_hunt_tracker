# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeLinesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/welcome_lines").to route_to("welcome_lines#index")
    end

    it "routes to #new" do
      expect(get: "/welcome_lines/new").to route_to("welcome_lines#new")
    end

    it "routes to #show" do
      expect(get: "/welcome_lines/1").to route_to("welcome_lines#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/welcome_lines/1/edit").to route_to("welcome_lines#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/welcome_lines").to route_to("welcome_lines#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/welcome_lines/1").to route_to("welcome_lines#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/welcome_lines/1").to route_to("welcome_lines#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/welcome_lines/1").to route_to("welcome_lines#destroy", id: "1")
    end
  end
end
