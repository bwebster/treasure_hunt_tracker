# frozen_string_literal: true

class RegisterChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "RegisterChannel subscribed in channels/register_channel.rb"
    stream_from "register_channel"
  end

  def unsubscribed
    Rails.logger.info "❌ Unsubscribed from register_channel"
  end

  def receive(data)
    Rails.logger.info "Received data: #{data}"
  end
end
