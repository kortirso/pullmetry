# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Reviews
        include Deps[
          entity_representer: 'services.import.representers.github.entity',
          monitoring: 'monitoring.client'
        ]

        STATE_MAPPER = {
          'APPROVED' => ::PullRequest::Review::ACCEPTED,
          'DISMISSED' => ::PullRequest::Review::REJECTED,
          'CHANGES_REQUESTED' => ::PullRequest::Review::ACCEPTED,
          'COMMENTED' => ::PullRequest::Review::COMMENTED
        }.freeze

        def call(data:)
          data.filter_map do |payload|
            payload = payload.with_indifferent_access
            state = STATE_MAPPER[payload[:state]]
            next monitor_unknown_state(payload) if state.nil?

            {
              external_id: payload[:id].to_s,
              review_created_at: payload[:submitted_at],
              author: entity_representer.call(data: payload[:user]),
              state: state,
              commit_external_id: payload[:commit_id]
            }
          end
        end

        def monitor_unknown_state(payload)
          monitoring.notify(
            exception: 'Github review has unknown state',
            metadata: { payload: payload },
            severity: :info
          )
          nil
        end
      end
    end
  end
end
