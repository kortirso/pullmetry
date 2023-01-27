# frozen_string_literal: true

module Import
  module Representers
    module Github
      class PullRequests
        def initialize(entity_representer: Entity.new)
          @entity_representer = entity_representer
        end

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              pull_number: payload[:number],
              pull_created_at: payload[:draft] ? nil : payload[:created_at],
              pull_closed_at: payload[:closed_at],
              pull_merged_at: payload[:merged_at],
              author: @entity_representer.call(data: payload[:user]),
              reviewers: payload[:requested_reviewers].map { |element| @entity_representer.call(data: element) }
            }
          end
        end
      end
    end
  end
end
