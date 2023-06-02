# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def omniauth_link(provider)
    case provider
    when :github then github_oauth_link
    end
  end

  private

  # rubocop: disable Layout/LineLength
  def github_oauth_link
    "https://github.com/login/oauth/authorize?scope=user:email&response_type=code&client_id=#{value(:github_oauth, :client_id)}&redirect_uri=#{value(:github_oauth, :redirect_url)}"
  end
  # rubocop: enable Layout/LineLength

  def value(provider_oauth, key)
    credentials.dig(provider_oauth, Rails.env.to_sym, key)
  end

  def credentials
    Rails.application.credentials
  end
end
