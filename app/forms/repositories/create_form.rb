# frozen_string_literal: true

module Repositories
  class CreateForm
    include Deps[validator: 'validators.repository']

    HOURS_FOR_OLD_INSIGHTS = 12

    def call(company:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      error = validate_existing_link(company.user, params[:link])
      return { errors: [error] } if error.present?

      { result: company.repositories.create!(params) }
    end

    private

    def validate_existing_link(user, link)
      existing_repository = Repository.find_by(link: link)
      return if existing_repository.nil?

      if user.available_repositories.ids.include?(existing_repository.id)
        return 'User has access to repository with the same link'
      end

      return 'Repository with the same link exists' if repository_with_insights_exists?(existing_repository)

      nil if existing_repository.destroy
    end

    def repository_with_insights_exists?(existing_repository)
      ::Insight
        .where(insightable: existing_repository)
        .exists?(['updated_at > ?', HOURS_FOR_OLD_INSIGHTS.hours.ago])
    end
  end
end
