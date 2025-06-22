# frozen_string_literal: true

class VoiceSettingsController < ApplicationController
  def edit
    @voice_setting = VoiceSetting.singleton
  end

  def update
    @voice_setting = VoiceSetting.singleton
    if @voice_setting.update(voice_setting_params)
      redirect_to admin_path, notice: "Voice settings were successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_voice_setting
    @voice_setting = VoiceSetting.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def voice_setting_params
    params.expect(voice_setting: %i[stability use_speaker_boost similarity_boost style speed voice_ids])
  end
end
