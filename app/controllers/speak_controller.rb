# frozen_string_literal: true

require "net/http"
require "numbers_and_words"

class SpeakController < AdminController
  include ActionView::Helpers::NumberHelper

  skip_before_action :verify_authenticity_token

  def progress
    settings = VoiceSetting.singleton

    if settings.api_key.blank?
      Rails.logger.info "Skipping TTS - no API key"
      return render json: {}, status: :no_content
    end

    tracking_event = TrackingEvent.find_by(id: params[:tracking_event_id])
    unless tracking_event
      Rails.logger.info "No tracking event found"
      return render json: {}, status: :no_content
    end

    username = if tracking_event.rfid_tag.user.present?
                 tracking_event.rfid_tag.user.username
               else
                 tracking_event.rfid_tag.label
               end

    location = tracking_event.location
    unless location
      Rails.logger.info "No location found"
      return render json: {}, status: :no_content
    end

    score = params[:score] || 0
    Rails.logger.info "*** Score is #{score} for user #{username}"

    text = if score.positive?
             score = Integer(score).to_words
             WelcomeLine
               .new(text: "{{username}}, you have {{score}} points!")
               .interpolate(
                 username:,
                 score:,
                 location: location.name
               )
           else
             WelcomeLine
               .new(text: "{{username}}, you have no points yet.")
               .interpolate(
                 username: username,
                 score:,
                 location: location.name
               )
           end
    Rails.logger.info "<<<< Generating audio for #{text}"

    settings = VoiceSetting.singleton

    Rails.logger.info "Calling TTS with settings: #{settings.as_json}"

    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{settings.rand_robotic_voice}/stream")
    req = Net::HTTP::Post.new(uri)
    req["xi-api-key"] = settings.api_key
    req["Content-Type"] = "application/json"
    req.body = {
      text:,
      model_id: settings.model_id,
      voice_settings: {
        stability: 0.80,
        similarity_boost: 0.80,
        speed: 0.9
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

  def tts
    settings = VoiceSetting.singleton

    if settings.api_key.blank?
      Rails.logger.info "Skipping TTS - no API key"
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

    Rails.logger.info "Calling TTS with settings: #{settings.as_json}"

    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{settings.rand_voice}/stream")
    req = Net::HTTP::Post.new(uri)
    req["xi-api-key"] = settings.api_key
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
