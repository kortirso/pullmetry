# frozen_string_literal: true

module AccessTokens
  class CreateForm
    include Deps[validator: 'validators.access_token']

    def call(tokenable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      error = validate_pat_token(tokenable, params[:value])
      return { errors: [error] } if error.present?

      ActiveRecord::Base.transaction do
        tokenable.access_token&.destroy
        tokenable.create_access_token!(params)
      end
    end

    private

    def validate_pat_token(tokenable, value)
      return validate_repository_token(tokenable, value) if tokenable.is_a?(Repository)

      validate_company_token(tokenable, value)
    end

    def validate_repository_token(tokenable, value)
      validate_provider_format(value, tokenable.provider)
    end

    def validate_company_token(tokenable, value)
      repositories_without_token = tokenable.repositories.where.missing(:access_token).pluck(:provider).uniq

      case repositories_without_token.size
      when 0 then validate_all_formats(value)
      when 1 then validate_provider_format(value, repositories_without_token[0])
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
  end
end
