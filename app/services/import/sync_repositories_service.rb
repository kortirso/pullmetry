# frozen_string_literal: true

module Import
  class SyncRepositoriesService
    prepend ApplicationService

    def initialize(
      sync_pull_requests_service: SyncPullRequestsService,
      sync_comments_service: SyncCommentsService,
      sync_reviews_service: SyncReviewsService,
      generate_insights_service: Insights::GenerateService,
      update_repository_service: Repositories::UpdateService.new
    )
      @sync_pull_requests_service = sync_pull_requests_service
      @sync_comments_service = sync_comments_service
      @sync_reviews_service = sync_reviews_service
      @generate_insights_service = generate_insights_service
      @update_repository_service = update_repository_service
    end

    def call(company:)
      company.repositories.each do |repository|
        @sync_pull_requests_service.new(repository: repository).call
        repository.pull_requests.each do |pull_request|
          @sync_comments_service.new(pull_request: pull_request).call
          @sync_reviews_service.new(pull_request: pull_request).call
        end
        @update_repository_service.call(repository: repository, params: { synced_at: DateTime.now })
        @generate_insights_service.call(insightable: repository)
      end
      @generate_insights_service.call(insightable: company)
    end
  end
end
