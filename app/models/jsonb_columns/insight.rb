# frozen_string_literal: true

module JsonbColumns
  class Insight
    include StoreModel::Model

    # attributes representing user reviewing
    attribute :required_reviews_count, :boolean
    attribute :comments_count, :boolean
    attribute :reviews_count, :boolean
    attribute :review_involving, :boolean
    attribute :average_review_seconds, :boolean
    attribute :reviewed_loc, :boolean
    attribute :average_reviewed_loc, :boolean

    # attributes representing user PRs quality
    attribute :open_pull_requests_count, :boolean
    attribute :average_merge_seconds, :boolean
    attribute :average_open_pr_comments, :boolean
    attribute :changed_loc, :boolean
    attribute :average_changed_loc, :boolean
  end
end
