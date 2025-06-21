# frozen_string_literal: true

require "rails_helper"

RSpec.describe "welcome_lines/new", type: :view do
  before(:each) do
    assign(:welcome_line, WelcomeLine.new(
                            text: "MyString"
                          ))
  end

  it "renders new welcome_line form" do
    render

    assert_select "form[action=?][method=?]", welcome_lines_path, "post" do
      assert_select "input[name=?]", "welcome_line[text]"
    end
  end
end
