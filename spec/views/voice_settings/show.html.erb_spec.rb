# frozen_string_literal: true

require "rails_helper"

RSpec.describe "voice_settings/show", type: :view do
  before(:each) do
    assign(:voice_setting, VoiceSetting.create!(
                             stability: "9.99",
                             use_speaker_boost: false,
                             similarity_boost: "9.99",
                             style: "9.99",
                             speed: "9.99",
                             voice_ids: "Voice Ids"
                           ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Voice Ids/)
  end
end
