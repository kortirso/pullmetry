# frozen_string_literal: true

module Import
  class SyncRepositoriesService
    prepend ApplicationService

    NOT_ACCESSABLE_LIMIT_TICKS = 10

    def initialize(
      sync_pull_requests_service: SyncPullRequestsService,
      sync_comments_service: SyncCommentsService,
      sync_reviews_service: SyncReviewsService,
      generate_insights_service: Insights::GenerateService,
      update_repository_service: Repositories::UpdateService.new,
      update_company_service: Companies::UpdateService
    )
      @sync_pull_requests_service = sync_pull_requests_service
      @sync_comments_service = sync_comments_service
      @sync_reviews_service = sync_reviews_service
      @generate_insights_service = generate_insights_service
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
        end
        update_repository(repository)
        @generate_insights_service.call(insightable: repository) if repository.accessable
      end

      finalize_sync(company)
    end
    # rubocop: enable Metrics/AbcSize

    private

    def update_repository(repository)
      # commento: repositories.synced_at
      @update_repository_service.call(repository: repository, params: { synced_at: DateTime.now })
    end

    def finalize_sync(company)
      not_accessable_count = company.repositories.where(accessable: false).count

      update_company_accessable(company, not_accessable_count.zero?)
      update_entities_cache(company)
      @generate_insights_service.call(insightable: company) if company.repositories_count != not_accessable_count
    end

    def update_company_accessable(company, accessable)
      not_accessable_ticks = accessable ? 0 : (company.not_accessable_ticks + 1)
      # commento: companies.accessable, companies.not_accessable_ticks
      @update_company_service.new.call(
        company: company,
        params: {
          accessable: accessable,
          not_accessable_ticks: not_accessable_ticks
        }
      )
      return if not_accessable_ticks != NOT_ACCESSABLE_LIMIT_TICKS

      Users::NotificationMailer.repository_access_error_email(id: company.user_id).deliver_now
    end

    def update_entities_cache(company)
      Entities::ForInsightableQuery
        .resolve(insightable: company)
        .hashable_pluck(:id, :html_url, :avatar_url, :login)
        .each do |payload|
          Rails.cache.write(
            "entity_payload_#{payload.delete(:id)}_v1",
            payload.symbolize_keys,
            expires_in: 12.hours
          )
        end
    end
  end
end
