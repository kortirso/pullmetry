# frozen_string_literal: true

module JsonbColumns
  class Configuration
    include StoreModel::Model

    attribute :private, :boolean, default: false
    # insights calculation attributes
    attribute :ignore_users_work_time, :boolean

    # TODO: remove 3 times
    attribute :work_time_zone, :string
    attribute :work_start_time, :datetime
    attribute :work_end_time, :datetime

    # insights table view attributes
    attribute :insight_fields, JsonbColumns::Insight.to_type
    attribute :insight_ratio, :boolean
    enum :insight_ratio_type, { ratio: 0, change: 1 }, default: :ratio
    attribute :rows_limit, :integer
    # data fetching attributes
    attribute :fetch_period, :integer
    # different
    attribute :long_time_review_hours, :integer
    enum :average_type, { arithmetic_mean: 0, median: 1, geometric_mean: 2 }, default: :arithmetic_mean
    enum :main_attribute,
         {
           required_reviews_count: 0, comments_count: 1, conventional_comments_count: 2, reviews_count: 3,
           bad_reviews_count: 4, average_review_seconds: 5, review_involving: 6, reviewed_loc: 7,
           average_reviewed_loc: 8, open_pull_requests_count: 9, time_since_last_open_pull_seconds: 10,
           average_merge_seconds: 11, average_open_pr_comments: 12, changed_loc: 13, average_changed_loc: 14
         }, default: :comments_count
    # TODO: configuration field for repository
    # attribute :start_from_pull_number, :integer
  end
end
