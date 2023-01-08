# frozen_string_literal: true

module ApplicationHelper
  def github_omniauth_link
    params = ['scope=user:email', 'provider_ignores_state=true', 'response_type=code']
    params << "client_id=#{credentials.dig(:github_oauth, Rails.env.to_sym, :client_id)}"
    params << "redirect_uri=#{credentials.dig(:github_oauth, Rails.env.to_sym, :redirect_url)}"
    "https://github.com/login/oauth/authorize?#{params.join('&')}"
  end

  def credentials
    Rails.application.credentials
  end
end
