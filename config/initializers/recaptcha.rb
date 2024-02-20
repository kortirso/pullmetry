# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = Rails.application.credentials.dig(:recaptcha, :public)
  config.secret_key = Rails.application.credentials.dig(:recaptcha, :private)
end
