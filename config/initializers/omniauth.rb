# frozen_string_literal: true

credentials = Rails.application.credentials

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  provider :github,
           credentials.dig(:github_oauth, Rails.env.to_sym, :client_id),
           credentials.dig(:github_oauth, Rails.env.to_sym, :client_secret),
           scope: 'user:email',
           redirect_url: credentials.dig(:github_oauth, Rails.env.to_sym, :redirect_url),
           provider_ignores_state: true
end
