# frozen_string_literal: true

credentials = Rails.application.credentials

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  if Rails.env.production?
    provider :github,
             credentials.dig(:github_oauth, :production, :client_id),
             credentials.dig(:github_oauth, :production, :client_secret),
             scope: 'user:email',
             redirect_url: credentials.dig(:github_oauth, :production, :redirect_url),
             provider_ignores_state: true
  else
    provider :github,
             credentials.dig(:github_oauth, :development, :client_id),
             credentials.dig(:github_oauth, :development, :client_secret),
             scope: 'user:email',
             redirect_url: credentials.dig(:github_oauth, :production, :redirect_url),
             provider_ignores_state: true
  end
end
