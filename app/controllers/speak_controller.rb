# frozen_string_literal: true

require "net/http"

class SpeakController < ApplicationController
  skip_before_action :verify_authenticity_token

  API_KEY = ENV["ELEVENLABS_API_KEY"]

  def tts
    unless API_KEY.present?
      Rails.logger.info "Skipping TTS"
      return render json: {}, status: :no_content
    end

    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{get_voice}/stream")
    req = Net::HTTP::Post.new(uri)
    req["xi-api-key"] = API_KEY
    req["Content-Type"] = "application/json"
    req.body = {
      text: params[:text],
      model_id: "eleven_flash_v2",
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.75,
        speed: 0.8
      }
    }.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req) do |response|
        self.response.headers["Content-Type"] = "audio/mpeg"
        self.response.headers["Cache-Control"] = "no-cache"
        self.response_body = response.body
      end
    end
  end

  private

  def get_voice
    voice_ids = ENV.fetch("ELEVENLABS_VOICE_IDS").split(",")
    voice_ids.sample
  end
end
