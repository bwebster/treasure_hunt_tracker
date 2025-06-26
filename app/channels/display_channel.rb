# frozen_string_literal: true

class DisplayChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "DisplayChannel subscribed in channels/display_channel.rb"
    stream_from "display_channel"
  end

  def unsubscribed
    Rails.logger.info "❌ Unsubscribed from display_channel"
  end

  def receive(data)
    Rails.logger.info "Received data: #{data}"
  end
end
