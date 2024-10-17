# frozen_string_literal: true

class PullRequest
  class Comment < ApplicationRecord
    self.table_name = :pull_requests_comments

    belongs_to :pull_request, class_name: '::PullRequest', counter_cache: :pull_requests_comments_count
    belongs_to :entity, class_name: '::Entity'
  end
end
