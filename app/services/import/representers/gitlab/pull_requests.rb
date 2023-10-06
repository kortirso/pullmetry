# frozen_string_literal: true

module Import
  module Representers
    module Gitlab
      class PullRequests
        include Deps[entity_representer: 'services.import.representers.gitlab.entity']

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              pull_number: payload[:iid],
              pull_created_at: payload[:draft] ? nil : payload[:created_at],
              pull_closed_at: payload[:closed_at],
              pull_merged_at: payload[:merged_at],
              author: entity_representer.call(data: payload[:author]),
              reviewers: payload[:reviewers].map { |element| entity_representer.call(data: element) },
              owner_avatar_url: nil
            }
          end
        end
      end
    end
  end
end
