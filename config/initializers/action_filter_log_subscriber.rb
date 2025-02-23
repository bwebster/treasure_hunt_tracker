
Rails.application.configure do
  config.after_initialize do
    ActiveSupport::Notifications.subscribe 'broadcast.action_cable' do |event|
      Rails.logger.info "Action Cable - #{event.inspect}"
    end
  end
end
