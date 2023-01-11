# frozen_string_literal: true

module Repositories
  class CreateService
    prepend ApplicationService
    include Validateable

    HOURS_FOR_OLD_INSIGHTS = 12

    def initialize(repository_validator: RepositoryValidator)
      @repository_validator = repository_validator
    end

    def call(company:, params:)
      return if validate_with(@repository_validator, params) && failure?
      return if validate_link(company.user, params[:link]) && failure?

      @result = company.repositories.create!(params)
    end

    private

    def validate_link(user, link)
      available_repositories = user.available_repositories
      return fail!('User has access to repository with the same link') if available_repositories.exists?(link: link)
      return fail!('Repository with the same link exists') if unavailable_repositories_exists?(available_repositories)
    end

    def unavailable_repositories_exists?(available_repositories)
      Repository
        .where.not(id: available_repositories)
        .where.associated(:insights)
        .exists?(['insights.updated_at > ?', HOURS_FOR_OLD_INSIGHTS.hours.ago])
    end
  end
end
