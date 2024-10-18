# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Issues
        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              issue_number: payload[:number],
              opened_at: payload[:created_at],
              closed_at: payload[:closed_at],
              title: payload[:title],
              description: payload[:body]
            }
          end
        end
      end
    end
  end
end
