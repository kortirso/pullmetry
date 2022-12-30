# frozen_string_literal: true

module Import
  module Representers
    class PullRequests
      def initialize(user_representer: User.new)
        @user_representer = user_representer
      end

      def call(data:)
        data.map do |payload|
          payload = payload.with_indifferent_access
          {
            pull_number: payload[:number],
            open: payload[:state] == 'open',
            pull_created_at: payload[:created_at],
            pull_closed_at: payload[:closed_at],
            pull_merged_at: payload[:merged_at],
            author: @user_representer.call(data: payload[:user]),
            reviewers: payload[:requested_reviewers].map { |element| @user_representer.call(data: element) }
          }
        end
      end
    end
  end
end
