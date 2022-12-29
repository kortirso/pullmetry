# frozen_string_literal: true

module Import
  module Representers
    class PullRequests
      def initialize(user_representer: User.new)
        @user_representer = user_representer
      end

      def call(data:)
        data.map do |payload|
          {
            pull_number: payload['number'],
            state: payload['state'],
            created_at: payload['created_at'],
            closed_at: payload['closed_at'],
            merged_at: payload['merged_at'],
            author: @user_representer.call(data: payload['user']),
            reviewers: payload['requested_reviewers'].map { |element| @user_representer.call(data: element) }
          }
        end
      end
    end
  end
end
