require 'rails_helper'

RSpec.describe "voice_settings/index", type: :view do
  before(:each) do
    assign(:voice_settings, [
      VoiceSetting.create!(
        stability: "9.99",
        use_speaker_boost: false,
        similarity_boost: "9.99",
        style: "9.99",
        speed: "9.99",
        voice_ids: "Voice Ids"
      ),
      VoiceSetting.create!(
        stability: "9.99",
        use_speaker_boost: false,
        similarity_boost: "9.99",
        style: "9.99",
        speed: "9.99",
        voice_ids: "Voice Ids"
      )
    ])
  end

  it "renders a list of voice_settings" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Voice Ids".to_s), count: 2
  end
end
