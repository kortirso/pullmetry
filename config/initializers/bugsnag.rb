# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials[:secret_key_bugsnag]
end
