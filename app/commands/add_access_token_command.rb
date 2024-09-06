# frozen_string_literal: true

class AddAccessTokenCommand < BaseCommand
  include Deps[remove_access_token: 'commands.remove_access_token']

  use_contract do
    params do
      required(:tokenable).filled(type_included_in?: [Company, Repository])
      required(:value).filled(:string)
      optional(:expired_at).maybe(:string)
    end
  end

  private

  def validate_content(input)
    validate_pat_token(input)
  end

  def do_prepare(input)
    input[:expired_at] = transform_expired_at(input[:expired_at]) if input[:expired_at]
  end

  def do_persist(input)
    access_token = ActiveRecord::Base.transaction do
      remove_access_token.call(access_token: input[:tokenable].access_token) if input[:tokenable].access_token
      AccessToken.create!(input)
    end

    { result: access_token }
  end

  def validate_pat_token(input)
    return validate_repository_token(input) if input[:tokenable].is_a?(Repository)

    validate_company_token(input)
  end

  def validate_repository_token(input)
    validate_provider_format(input[:value], input[:tokenable].provider)
  end

  def validate_company_token(input)
    repositories_without_token = input[:tokenable].repositories.where.missing(:access_token).pluck(:provider).uniq

    case repositories_without_token.size
    when 0 then validate_all_formats(input[:value])
    when 1 then validate_provider_format(input[:value], repositories_without_token[0])
    else 'Company has repositories of multiple providers'
    end
  end

  def validate_provider_format(value, provider)
    return if value.starts_with?(AccessToken::FORMAT_BY_PROVIDER[provider])

    'Invalid PAT token format'
  end

  def validate_all_formats(value)
    return if AccessToken::FORMAT_BY_PROVIDER.values.any? { |format| value.starts_with?(format) }

    'Invalid PAT token format'
  end

  def transform_expired_at(value)
    DateTime.parse(value)
  rescue Date::Error => _e
  end
end
