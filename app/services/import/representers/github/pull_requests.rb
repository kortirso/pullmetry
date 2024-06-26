# frozen_string_literal: true

module Import
  module Representers
    module Github
      class PullRequests
        include Deps[entity_representer: 'services.import.representers.github.entity']

        # rubocop: disable Metrics/AbcSize
        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              pull_number: payload[:number],
              pull_created_at: payload[:draft] ? nil : payload[:created_at],
              pull_closed_at: payload[:closed_at],
              pull_merged_at: payload[:merged_at],
              author: entity_representer.call(data: payload[:user]),
              reviewers: payload[:requested_reviewers].map { |element| entity_representer.call(data: element) },
              owner_avatar_url: payload.dig('base', 'repo', 'owner', 'avatar_url'),
              title: payload[:title],
              description: payload[:body],
              branch_name: payload.dig('head', 'ref'),
              destination_branch_name: payload.dig('base', 'ref'),
              last_commit_external_id: payload.dig('head', 'sha')
            }
          end
        end
        # rubocop: enable Metrics/AbcSize
      end
    end
  end
end
