require 'rails_helper'

RSpec.describe "welcome_lines/index", type: :view do
  before(:each) do
    assign(:welcome_lines, [
      WelcomeLine.create!(
        text: "Text"
      ),
      WelcomeLine.create!(
        text: "Text"
      )
    ])
  end

  it "renders a list of welcome_lines" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Text".to_s), count: 2
  end
end
