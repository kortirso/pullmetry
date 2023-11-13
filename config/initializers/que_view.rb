# frozen_string_literal: true

Que::View.configure do |config|
  config.ui_username = credentials.dig(:que_view, :username)
  config.ui_password = credentials.dig(:que_view, :password)
  config.ui_secured_environments = ['production']
end
