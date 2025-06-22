# frozen_string_literal: true

require "rails_helper"

RSpec.describe "voice_settings/new", type: :view do
  before(:each) do
    assign(:voice_setting, VoiceSetting.new(
                             stability: "9.99",
                             use_speaker_boost: false,
                             similarity_boost: "9.99",
                             style: "9.99",
                             speed: "9.99",
                             voice_ids: "MyString"
                           ))
  end

  it "renders new voice_setting form" do
    render

    assert_select "form[action=?][method=?]", voice_settings_path, "post" do
      assert_select "input[name=?]", "voice_setting[stability]"

      assert_select "input[name=?]", "voice_setting[use_speaker_boost]"

      assert_select "input[name=?]", "voice_setting[similarity_boost]"

      assert_select "input[name=?]", "voice_setting[style]"

      assert_select "input[name=?]", "voice_setting[speed]"

      assert_select "input[name=?]", "voice_setting[voice_ids]"
    end
  end
end
