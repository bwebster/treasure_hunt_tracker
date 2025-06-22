# frozen_string_literal: true

require "net/http"

class SpeakController < AdminController
  skip_before_action :verify_authenticity_token

  API_KEY = ENV["ELEVENLABS_API_KEY"]

  def tts
    if API_KEY.blank?
      Rails.logger.info "Skipping TTS"
      return render json: {}, status: :no_content
    end

    user = User.find_by(id: params[:user_id])
    unless user
      Rails.logger.info "No user found"
      return render json: {}, status: :no_content
    end

    location = Location.find_by(id: params[:location_id])
    unless location
      Rails.logger.info "No location found"
      return render json: {}, status: :no_content
    end

    text = WelcomeLine.all.sample.interpolate(
      username: user.username,
      location: location.name
    )

    settings = VoiceSetting.singleton

    Rails.logger.info "Calling TTS with settings: #{settings.as_json}"

    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{settings.rand_voice}/stream")
    req = Net::HTTP::Post.new(uri)
    req["xi-api-key"] = API_KEY
    req["Content-Type"] = "application/json"
    req.body = {
      text:,
      model_id: settings.model_id,
      voice_settings: {
        stability: settings.stability,
        use_speaker_boost: settings.use_speaker_boost,
        similarity_boost: settings.similarity_boost,
        style: settings.style,
        speed: settings.speed
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
end
