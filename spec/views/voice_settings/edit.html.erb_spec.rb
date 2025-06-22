# frozen_string_literal: true

require "rails_helper"

RSpec.describe "voice_settings/edit", type: :view do
  let(:voice_setting) do
    VoiceSetting.create!(
      stability: "9.99",
      use_speaker_boost: false,
      similarity_boost: "9.99",
      style: "9.99",
      speed: "9.99",
      voice_ids: "MyString"
    )
  end

  before(:each) do
    assign(:voice_setting, voice_setting)
  end

  it "renders the edit voice_setting form" do
    render

    assert_select "form[action=?][method=?]", voice_setting_path(voice_setting), "post" do
      assert_select "input[name=?]", "voice_setting[stability]"

      assert_select "input[name=?]", "voice_setting[use_speaker_boost]"

      assert_select "input[name=?]", "voice_setting[similarity_boost]"

      assert_select "input[name=?]", "voice_setting[style]"

      assert_select "input[name=?]", "voice_setting[speed]"

      assert_select "input[name=?]", "voice_setting[voice_ids]"
    end
  end
end
