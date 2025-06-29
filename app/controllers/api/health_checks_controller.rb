# frozen_string_literal: true

module Api
  class HealthChecksController < ApplicationController
    skip_before_action :verify_authenticity_token

    rescue_from StandardError, with: :handle_exception

    def index
      location = Location.find_by(number: params[:l])
      return render json: { e: "Bad location" }, status: :bad_request unless location

      HealthCheck.create!(location:)
      render json: {}
    end

    private

    def handle_exception(exception)
      Rails.logger.error("HealthChecksController error: #{exception.message} #{exception.backtrace.join("\n")}")
      render json: {
        error: exception.message,
        backtrace: exception.backtrace.take(10) # Return first 10 lines of the backtrace
      }, status: :internal_server_error
    end
  end
end
