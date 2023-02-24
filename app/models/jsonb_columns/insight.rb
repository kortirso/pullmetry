# frozen_string_literal: true

module JsonbColumns
  class Insight
    include StoreModel::Model

    # insights calculation attributes
    attribute :comments_count, :boolean
    attribute :reviews_count, :boolean
    attribute :required_reviews_count, :boolean
    attribute :open_pull_requests_count, :boolean
    attribute :average_open_pr_comments, :boolean
    attribute :average_review_seconds, :boolean
    attribute :average_merge_seconds, :boolean
  end
end
