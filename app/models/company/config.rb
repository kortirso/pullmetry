# frozen_string_literal: true

class Company
  class Config
    include StoreModel::Model

    attribute :private, :boolean, default: false
    attribute :ignore_users_work_time, :boolean, default: false
    attribute :insight_fields, Company::EnabledInsightsConfig.to_type, default: -> { {} }
    attribute :insight_ratio, :boolean, default: false
    enum :insight_ratio_type, { ratio: 0, change: 1 }, default: :ratio
    attribute :fetch_period, :integer, default: Insight::FETCH_DAYS_PERIOD
    attribute :long_time_review_hours, :integer, default: 48
    enum :average_type, { arithmetic_mean: 0, median: 1, geometric_mean: 2 }, default: :arithmetic_mean
    enum :main_attribute,
         {
           required_reviews_count: 0, comments_count: 1, conventional_comments_count: 2, reviews_count: 3,
           bad_reviews_count: 4, average_review_seconds: 5, review_involving: 6, reviewed_loc: 7,
           average_reviewed_loc: 8, open_pull_requests_count: 9, time_since_last_open_pull_seconds: 10,
           average_merge_seconds: 11, average_open_pr_comments: 12, changed_loc: 13, average_changed_loc: 14
         }, default: :comments_count

    def selected_insight_fields
      insight_fields.attributes.filter_map { |key, value| value ? key : nil }
    end
  end
end
