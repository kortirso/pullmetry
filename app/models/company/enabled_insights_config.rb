# frozen_string_literal: true

class Company
  class EnabledInsightsConfig
    include StoreModel::Model

    # attributes representing user reviewing
    attribute :required_reviews_count, :boolean, default: false
    attribute :comments_count, :boolean, default: true
    attribute :conventional_comments_count, :boolean, default: false
    attribute :reviews_count, :boolean, default: true
    attribute :bad_reviews_count, :boolean, default: true
    attribute :review_involving, :boolean, default: false
    attribute :average_review_seconds, :boolean, default: true
    attribute :reviewed_loc, :boolean, default: false
    attribute :average_reviewed_loc, :boolean, default: true

    # attributes representing user PRs quality
    attribute :open_pull_requests_count, :boolean, default: true
    attribute :time_since_last_open_pull_seconds, :boolean, default: true
    attribute :average_merge_seconds, :boolean, default: false
    attribute :average_open_pr_comments, :boolean, default: false
    attribute :changed_loc, :boolean, default: false
    attribute :average_changed_loc, :boolean, default: true
  end
end
