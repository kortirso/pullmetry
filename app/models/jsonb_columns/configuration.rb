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
    enum :insight_ratio_type, %i[ratio change], default: :ratio
    attribute :rows_limit, :integer
    # data fetching attributes
    attribute :fetch_period, :integer
    # different
    attribute :long_time_review_hours, :integer
    enum :average_type, %i[arithmetic_mean median geometric_mean], default: :arithmetic_mean
    enum :main_attribute,
         %i[
           required_reviews_count
           comments_count
           conventional_comments_count
           reviews_count
           bad_reviews_count
           average_review_seconds
           review_involving
           reviewed_loc
           average_reviewed_loc
           open_pull_requests_count
           time_since_last_open_pull_seconds
           average_merge_seconds
           average_open_pr_comments
           changed_loc
           average_changed_loc
         ],
         default: :comments_count
    # TODO: configuration field for repository
    # attribute :start_from_pull_number, :integer
  end
end
