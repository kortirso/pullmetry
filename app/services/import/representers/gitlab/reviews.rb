# frozen_string_literal: true

module Import
  module Representers
    module Gitlab
      class Reviews
        include Deps[entity_representer: 'services.import.representers.gitlab.entity']

        def call(data:)
          data['approved_by'].map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload.dig('user', 'id'),
              review_created_at: data[:updated_at],
              author: entity_representer.call(data: payload[:user]),
              state: PullRequests::Review::APPROVED,
              commit_external_id: nil
            }
          end
        end
      end
    end
  end
end
