require 'rails_helper'

RSpec.describe "welcome_lines/edit", type: :view do
  let(:welcome_line) {
    WelcomeLine.create!(
      text: "MyString"
    )
  }

  before(:each) do
    assign(:welcome_line, welcome_line)
  end

  it "renders the edit welcome_line form" do
    render

    assert_select "form[action=?][method=?]", welcome_line_path(welcome_line), "post" do

      assert_select "input[name=?]", "welcome_line[text]"
    end
  end
end
