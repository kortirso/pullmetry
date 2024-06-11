# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

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
    "https://github.com/login/oauth/authorize?scope=user:email&response_type=code&client_id=#{value(:github_oauth, :client_id)}&redirect_uri=#{value(:github_oauth, :redirect_url)}"
  end

  def gitlab_oauth_link
    "https://gitlab.com/oauth/authorize?scope=read_user&response_type=code&client_id=#{value(:gitlab_oauth, :client_id)}&redirect_uri=#{value(:gitlab_oauth, :redirect_url)}"
  end

  def google_oauth_link
    "https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&response_type=code&client_id=#{value(:google_oauth, :client_id)}&redirect_uri=#{value(:google_oauth, :redirect_url)}"
  end
  # rubocop: enable Layout/LineLength

  def value(provider_oauth, key)
    Rails.application.credentials.dig(provider_oauth, Rails.env.to_sym, key)
  end

  def react_component(component_name, **props)
    content_tag(
      'div',
      id: props[:component_id],
      class: props[:component_class],
      data: {
        react_component: component_name,
        props: props.except(:component_id, :component_class, :children).to_json
      }
    ) { props[:children]&.to_json || '' }
  end
end
