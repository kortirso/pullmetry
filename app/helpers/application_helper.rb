# frozen_string_literal: true

module ApplicationHelper
  def github_omniauth_link
    "https://github.com/login/oauth/authorize?client_id=#{credentials.dig(:github_oauth, Rails.env.to_sym, :client_id)}&redirect_uri=#{credentials.dig(:github_oauth, Rails.env.to_sym, :redirect_url)}&scope=user:email&provider_ignores_state=true&response_type=code"
  end

  def credentials
    Rails.application.credentials
  end
end
