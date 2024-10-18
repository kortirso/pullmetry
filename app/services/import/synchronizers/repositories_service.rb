# frozen_string_literal: true

module Import
  module Synchronizers
    class RepositoriesService
      # rubocop: disable Metrics/AbcSize
      def call(repository:)
        import_time = DateTime.now

        sync_pull_requests_service.call(repository: repository)
        repository.pull_requests.opened_before(import_time).each do |pull_request|
          sync_comments_service.call(pull_request: pull_request)
          sync_reviews_service.call(pull_request: pull_request)
          sync_files_service.call(pull_request: pull_request)
        end
        sync_issues_service.call(repository: repository)
        repository.issues.opened_before(import_time).each do |issue|
          sync_issue_comments_service.call(issue: issue)
        end
        update_repository(repository)
        generate_insights_service.call(insightable: repository) if repository.accessable
      end
      # rubocop: enable Metrics/AbcSize

      private

      def update_repository(repository)
        # commento: repositories.synced_at, repositories.pull_requests_count
        change_repository.call(
          repository: repository,
          synced_at: DateTime.now,
          pull_requests_count: repository.pull_requests.actual(repository.find_fetch_period).count
        )
      end

      def sync_pull_requests_service = raise NotImplementedError
      def sync_comments_service = raise NotImplementedError
      def sync_reviews_service = raise NotImplementedError
      def sync_files_service = raise NotImplementedError
      def sync_issues_service = raise NotImplementedError
      def sync_issue_comments_service = raise NotImplementedError
      def update_service = raise NotImplementedError
      def generate_insights_service = Insights::Generate::RepositoryService.new
    end
  end
end
