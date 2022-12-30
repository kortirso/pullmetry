# frozen_string_literal: true

module Import
  module Savers
    class PullRequests
      prepend ApplicationService

      def call(repository:, data:)
        @repository = repository

        ActiveRecord::Base.transaction do
          destroy_old_pull_requests(data)
          data.each do |payload|
            save_author(payload.delete(:author))
            payload.delete(:reviewers).each { |reviewer| save_reviewer(reviewer) }
            save_pull_request(payload)
          end
        end
      end

      private

      def destroy_old_pull_requests(data)
        @repository
          .pull_requests
          .where.not(pull_number: data.pluck(:pull_number))
          .destroy_all
      end

      def save_author(_payload); end

      def save_reviewer(_payload); end

      def save_pull_request(payload)
        pull_request = @repository.pull_requests.find_or_initialize_by(pull_number: payload.delete(:pull_number))
        pull_request.update!(payload)
      end
    end
  end
end
