# frozen_string_literal: true

module Authkeeper
  module ApplicationHelper
    def omniauth_link(provider)
      case provider
      when :github then github_oauth_link
      when :gitlab then gitlab_oauth_link
      when :google then google_oauth_link
      end
    end

    private

    # rubocop: disable Layout/LineLength
    def github_oauth_link
      "https://github.com/login/oauth/authorize?scope=user:email&response_type=code&client_id=#{value(:github, :client_id)}&redirect_uri=#{value(:github, :redirect_url)}"
    end

    def gitlab_oauth_link
      "https://gitlab.com/oauth/authorize?scope=read_user&response_type=code&client_id=#{value(:gitlab, :client_id)}&redirect_uri=#{value(:gitlab, :redirect_url)}"
    end

    def google_oauth_link
      "https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&response_type=code&client_id=#{value(:google, :client_id)}&redirect_uri=#{value(:google, :redirect_url)}"
    end
    # rubocop: enable Layout/LineLength

    def value(provider, key)
      Authkeeper.configuration.omniauth_configs.dig(provider, key)
    end
  end
end
