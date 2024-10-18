# frozen_string_literal: true

module Import
  module Representers
    module Github
      class IssueComments
        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload[:id].to_s,
              comment_created_at: payload[:created_at]
            }
          end
        end
      end
    end
  end
end
