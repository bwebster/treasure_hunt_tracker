# frozen_string_literal: true

class ViewTagChannel < ApplicationCable::Channel
  def subscribed
    stream_from "view_tag_channel"
    Rails.logger.info "🎥 Streaming from view_tag_channel"
  end

  def unsubscribed
    Rails.logger.info "❌ Unsubscribed from view_tag_channel"
  end
end
