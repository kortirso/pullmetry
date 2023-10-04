# frozen_string_literal: true

module Import
  class SyncRepositoriesService
    prepend ApplicationService

    NOT_ACCESSABLE_LIMIT_TICKS = 10

    def initialize(
      sync_pull_requests_service: SyncPullRequestsService,
      sync_comments_service: SyncCommentsService,
      sync_reviews_service: SyncReviewsService,
      sync_files_service: SyncFilesService,
      generate_repository_insights_service: Insights::Generate::RepositoryService,
      generate_company_insights_service: Insights::Generate::CompanyService,
      update_repository_service: Pullmetry::Container['services.persisters.repositories.update'],
      update_company_service: Pullmetry::Container['services.persisters.companies.update']
    )
      @sync_pull_requests_service = sync_pull_requests_service
      @sync_comments_service = sync_comments_service
      @sync_reviews_service = sync_reviews_service
      @sync_files_service = sync_files_service
      @generate_repository_insights_service = generate_repository_insights_service
      @generate_company_insights_service = generate_company_insights_service
      @update_repository_service = update_repository_service
      @update_company_service = update_company_service

      @import_time = DateTime.now
    end

    # rubocop: disable Metrics/AbcSize
    def call(company:)
      company.repositories.each do |repository|
        next if repository.fetch_access_token.nil?

        @sync_pull_requests_service.new(repository: repository).call
        repository.pull_requests.opened_before(@import_time).each do |pull_request|
          @sync_comments_service.new(pull_request: pull_request).call
          @sync_reviews_service.new(pull_request: pull_request).call
          @sync_files_service.new(pull_request: pull_request).call
        end
        update_repository(repository)
        @generate_repository_insights_service.call(insightable: repository) if repository.accessable
      end

      finalize_sync(company)
    end
    # rubocop: enable Metrics/AbcSize

    private

    def update_repository(repository)
      # commento: repositories.synced_at, repositories.pull_requests_count
      @update_repository_service.call(
        repository: repository,
        params: {
          synced_at: DateTime.now,
          pull_requests_count: repository.pull_requests.actual.count
        }
      )
    end

    def finalize_sync(company)
      not_accessable_count = company.repositories.where(accessable: false).count

      update_company_accessable(company, not_accessable_count.zero?)
      refresh_entities_cache(company)
      return if company.repositories_count == not_accessable_count

      @generate_company_insights_service.call(insightable: company)
    end

    def update_company_accessable(company, accessable)
      not_accessable_ticks = accessable ? 0 : (company.not_accessable_ticks + 1)
      # commento: companies.accessable, companies.not_accessable_ticks
      @update_company_service.call(
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
