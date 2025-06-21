require 'rails_helper'

RSpec.describe "welcome_lines/show", type: :view do
  before(:each) do
    assign(:welcome_line, WelcomeLine.create!(
      text: "Text"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Text/)
  end
end
