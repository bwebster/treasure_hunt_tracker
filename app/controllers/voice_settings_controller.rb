# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

class VoiceSettingsController < AdminController
  Usage = Struct.new(
    :character_count,
    :character_limit,
    :pct_used,
    keyword_init: true
  ) do
    def self.unknown
      new(character_limit: 0)
    end

    def known?
      !character_limit.zero?
    end
  end

  def edit
    @voice_setting = VoiceSetting.singleton
    @usage = usage
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

  def voice_setting_params
    params.expect(voice_setting: %i[api_key stability use_speaker_boost similarity_boost style speed voice_ids robot_voice_ids])
  end

  def usage
    api_key = VoiceSetting.singleton.api_key
    return Usage.unknown unless api_key

    uri = URI("https://api.elevenlabs.io/v1/user/subscription")
    req = Net::HTTP::Get.new(uri)
    req["xi-api-key"] = api_key

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Failed to fetch usage: #{res.code} #{res.message}"
      return Usage.unknown
    end

    data = JSON.parse(res.body)
    character_count = data["character_count"]
    character_limit = data["character_limit"]
    pct_used = (character_count.to_f / character_limit * 100).round(2)

    Usage.new(
      character_count:,
      character_limit:,
      pct_used:
    )
  end
end
