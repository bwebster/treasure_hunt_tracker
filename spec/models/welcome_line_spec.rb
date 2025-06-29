# frozen_string_literal: true

# == Schema Information
#
# Table name: welcome_lines
#
#  id         :uuid             not null, primary key
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe WelcomeLine, type: :model do
  describe ".interpolate" do
    it "replaces username" do
      model = FactoryBot.build(:welcome_line, text: "Hello {{username}}!")
      result = model.interpolate(username: "John", location: "Place")
      expect(result).to eq("Hello John!")
    end

    it "replaces location" do
      model = FactoryBot.build(:welcome_line, text: "Welcome to {{location}}!")
      result = model.interpolate(username: "John", location: "Place")
      expect(result).to eq("Welcome to Place!")
    end

    it "replaces score" do
      model = FactoryBot.build(:welcome_line, text: "You scored {{score}}!")
      result = model.interpolate(username: "John", location: "Place", score: 10)
      expect(result).to eq("You scored 10!")
    end
  end

  describe "validations" do
    context "when template is malformed" do
      it "is invalid" do
        model = FactoryBot.build(:welcome_line, text: "Hello {{username")
        expect(model).to_not be_valid
      end
    end

    context "when template has unknown variable" do
      it "is invalid" do
        model = FactoryBot.build(:welcome_line, text: "Hello {{name}}")
        expect(model).to_not be_valid
      end
    end

    context "when text is blank" do
      it "is invalid" do
        model = FactoryBot.build(:welcome_line, text: "")
        expect(model).to_not be_valid
      end
    end
  end
end
