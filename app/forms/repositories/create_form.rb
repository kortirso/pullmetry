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
      available_repositories = user.available_repositories
      return 'User has access to repository with the same link' if available_repositories.exists?(link: link)

      'Repository with the same link exists' if repository_exists?(available_repositories, link)
    end

    def repository_exists?(available_repositories, link)
      Repository
        .where.not(id: available_repositories)
        .where(link: link)
        .where.associated(:insights)
        .exists?(['insights.updated_at > ?', HOURS_FOR_OLD_INSIGHTS.hours.ago])
    end
  end
end
