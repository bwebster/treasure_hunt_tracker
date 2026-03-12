# frozen_string_literal: true

require "net/http"
require "numbers_and_words"

class SpeakController < AdminController
  include ActionView::Helpers::NumberHelper

  skip_before_action :verify_authenticity_token

  POSITIVE_SCORE_MESSAGES = [
    "{{username}}, you have {{score}} points!",
    "Good job {{username}}, {{score}} points!",
    "Attention everyone! {{username}} has {{score}} points.",
    "{{score}} points!  Keep up the good work {{username}}!"
  ].freeze

  ZERO_SCORE_MESSAGES = [
    "{{username}}, see Mr. Potato Head for points.",
    "{{username}}, you have no points yet.",
    "{{username}}, visit the Barbie dream house for points.",
    "{{username}}, points are hiding by the front doors."
  ].freeze

  def progress
    settings = VoiceSetting.singleton

    return render(json: {}, status: :no_content) if settings.api_key.blank?

    tracking_event = TrackingEvent.find_by(id: params[:tracking_event_id])
    unless tracking_event
      Rails.logger.info "No tracking event found"
      return render json: {}, status: :no_content
    end

    username = tracking_event.rfid_tag.user&.username || tracking_event.rfid_tag.label
    location = tracking_event.location
    unless location
      Rails.logger.info "No location found"
      return render json: {}, status: :no_content
    end

    score = params[:score] || 0
    Rails.logger.info "*** Score is #{score} for user #{username}"

    text = build_progress_message(username, score, location)
    Rails.logger.info "<<<< Generating audio for #{text}"

    send_tts_request(settings, text, settings.rand_robotic_voice, robotic_voice_settings)
  end

  def tts
    settings = VoiceSetting.singleton

    return render(json: {}, status: :no_content) if settings.api_key.blank?

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

    send_tts_request(settings, text, settings.rand_voice, user_voice_settings(settings))
  end

  private

  def build_progress_message(username, score, location)
    lines = score.positive? ? POSITIVE_SCORE_MESSAGES : ZERO_SCORE_MESSAGES
    line = lines.sample
    score_value = score.positive? ? Integer(score).to_words : score

    WelcomeLine.new(text: line).interpolate(
      username: username,
      score: score_value,
      location: location.name
    )
  end

  def robotic_voice_settings
    {
      stability: 0.80,
      similarity_boost: 0.80,
      speed: 0.9
    }
  end

  def user_voice_settings(settings)
    {
      stability: settings.stability,
      use_speaker_boost: settings.use_speaker_boost,
      similarity_boost: settings.similarity_boost,
      style: settings.style,
      speed: settings.speed
    }
  end

  def send_tts_request(settings, text, voice_id, voice_settings)
    Rails.logger.info "Calling TTS with settings: #{settings.as_json}"

    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}/stream")
    req = Net::HTTP::Post.new(uri)
    req["xi-api-key"] = settings.api_key
    req["Content-Type"] = "application/json"
    req.body = {
      text:,
      model_id: settings.model_id,
      voice_settings: voice_settings
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
