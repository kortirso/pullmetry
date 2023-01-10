# frozen_string_literal: true

module Import
  class SyncRepositoriesService
    prepend ApplicationService

    def initialize(
      sync_pull_requests_service: SyncPullRequestsService.new,
      sync_comments_service: SyncCommentsService.new,
      sync_reviews_service: SyncReviewsService.new,
      generate_insights_service: Insights::GenerateService.new
    )
      @sync_pull_requests_service = sync_pull_requests_service
      @sync_comments_service = sync_comments_service
      @sync_reviews_service = sync_reviews_service
      @generate_insights_service = generate_insights_service
    end

    def call(company:)
      company.repositories.includes(:pull_requests).each do |repository|
        @sync_pull_requests_service.call(repository: repository)
        repository.pull_requests.each do |pull_request|
          @sync_comments_service.call(pull_request: pull_request)
          @sync_reviews_service.call(pull_request: pull_request)
        end
        @generate_insights_service.call(insightable: repository)
      end
      @generate_insights_service.call(insightable: company)
    end
  end
end
