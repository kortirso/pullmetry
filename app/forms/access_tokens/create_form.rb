# frozen_string_literal: true

module AccessTokens
  class CreateForm
    include Deps[validator: 'validators.access_token']

    FORMAT_BY_PROVIDER = {
      Providerable::GITHUB => 'github_pat_',
      Providerable::GITLAB => 'glpat-'
    }.freeze

    def call(tokenable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      error = validate_github_pat_token(tokenable, params[:value])
      return { errors: [error] } if error.present?

      ActiveRecord::Base.transaction do
        tokenable.access_token&.destroy
        tokenable.create_access_token!(params)
      end
    end

    private

    def validate_github_pat_token(tokenable, value)
      return unless tokenable.is_a?(Repository)

      'Invalid PAT token format' unless value.starts_with?(FORMAT_BY_PROVIDER[tokenable.provider])
    end
  end
end
