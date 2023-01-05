# frozen_string_literal: true

credentials = Rails.application.credentials

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  if Rails.env.production?
    # TODO: add real providers
  else
    provider :github,
             credentials.dig(:github_oauth, :development, :client_id),
             credentials.dig(:github_oauth, :development, :client_secret),
             scope: 'user:email',
             callback_url: 'http://localhost:5000/auth/github/callback',
             provider_ignores_state: true
  end
end