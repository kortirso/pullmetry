# frozen_string_literal: true

module ApplicationHelper
  def github_omniauth_link
    "https://github.com/login/oauth/authorize?client_id=#{credentials.dig(:github_oauth, Rails.env.to_sym, :client_id)}&redirect_uri=#{credentials.dig(:github_oauth, Rails.env.to_sym, :redirect_url)}&scope=user:email"
  end

  def credentials
    Rails.application.credentials
  end
end
