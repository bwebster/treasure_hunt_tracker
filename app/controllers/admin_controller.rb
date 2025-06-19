# frozen_string_literal: true

class AdminController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate

  private

  def sorting(column, direction = "asc")
    sort_column = params[:sort] || column
    sort_direction = params[:direction] || direction
    { sort_column => sort_direction }
  end

  def authenticate
    return unless Rails.env.production? # Only enable auth in production

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USERNAME"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
