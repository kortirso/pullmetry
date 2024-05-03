# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Reviews
        include Deps[entity_representer: 'services.import.representers.github.entity']

        STATE_MAPPER = {
          'APPROVED' => ::PullRequests::Review::ACCEPTED,
          'DISMISSED' => ::PullRequests::Review::REJECTED,
          'COMMENTED' => ::PullRequests::Review::COMMENTED
        }.freeze

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload[:id].to_s,
              review_created_at: payload[:submitted_at],
              author: entity_representer.call(data: payload[:user]),
              state: STATE_MAPPER[payload[:state]],
              commit_external_id: payload[:commit_id]
            }
          end
        end
      end
    end
  end
end
