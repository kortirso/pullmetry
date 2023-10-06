# frozen_string_literal: true

module Import
  class CompanyService
    NOT_ACCESSABLE_LIMIT_TICKS = 10

    def initialize(
      sync_repository_from_github: Pullmetry::Container['services.import.repositories.github'],
      sync_repository_from_gitlab: Pullmetry::Container['services.import.repositories.gitlab'],
      generate_insights_service: Insights::Generate::CompanyService.new,
      update_service: Pullmetry::Container['services.persisters.companies.update']
    )
      @sync_repository_from_github = sync_repository_from_github
      @sync_repository_from_gitlab = sync_repository_from_gitlab
      @generate_insights_service = generate_insights_service
      @update_service = update_service
    end

    def call(company:)
      company.repositories.each do |repository|
        next if repository.fetch_access_token.nil?

        case repository.provider
        when Providerable::GITHUB then @sync_repository_from_github.call(repository: repository)
        when Providerable::GITLAB then @sync_repository_from_gitlab.call(repository: repository)
        end
      end

      finalize_sync(company)
    end

    private

    def finalize_sync(company)
      not_accessable_count = company.repositories.where(accessable: false).count

      update_company_accessable(company, not_accessable_count.zero?)
      refresh_entities_cache(company)
      return if company.repositories_count == not_accessable_count

      @generate_insights_service.call(insightable: company)
    end

    def update_company_accessable(company, accessable)
      not_accessable_ticks = accessable ? 0 : (company.not_accessable_ticks + 1)
      # commento: companies.accessable, companies.not_accessable_ticks
      @update_service.call(
        company: company,
        params: {
          accessable: accessable,
          not_accessable_ticks: not_accessable_ticks
        }
      )
      return if not_accessable_ticks != NOT_ACCESSABLE_LIMIT_TICKS

      Users::NotificationMailer.repository_access_error_email(id: company.user_id).deliver_now
    end

    def refresh_entities_cache(company)
      Entities::ForInsightableQuery
        .resolve(insightable: company)
        .hashable_pluck(:id, :html_url, :avatar_url, :login)
        .each do |payload|
          Rails.cache.write(
            "entity_payload_#{payload.delete(:id)}_v1",
            payload.symbolize_keys
          )
        end
    end
  end
end
