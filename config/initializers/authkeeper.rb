# frozen_string_literal: true

credentials = Rails.application.credentials.dig(Rails.env.to_sym, :oauth) || {}

Authkeeper.configure do |config|
  config.access_token_name = :pullmetry_access_token

  config.omniauth_providers = %w[github gitlab google telegram]

  config.omniauth :github,
                  client_id: credentials.dig(:github, :client_id),
                  client_secret: credentials.dig(:github, :client_secret),
                  redirect_url: credentials.dig(:github, :redirect_url)

  config.omniauth :gitlab,
                  client_id: credentials.dig(:gitlab, :client_id),
                  client_secret: credentials.dig(:gitlab, :client_secret),
                  redirect_url: credentials.dig(:gitlab, :redirect_url)

  config.omniauth :google,
                  client_id: credentials.dig(:google, :client_id),
                  client_secret: credentials.dig(:google, :client_secret),
                  redirect_url: credentials.dig(:google, :redirect_url)

  config.omniauth :telegram,
                  bot_name: credentials.dig(:telegram, :bot_name),
                  bot_secret: credentials.dig(:telegram, :bot_secret),
                  redirect_url: credentials.dig(:telegram, :redirect_url)
end
