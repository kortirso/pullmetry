# frozen_string_literal: true

return unless Rails.env.production?

# :skippit:
Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials[:secret_key_bugsnag]
end
# :skippit:
