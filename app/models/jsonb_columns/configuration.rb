# frozen_string_literal: true

module JsonbColumns
  class Configuration
    include StoreModel::Model

    # insights calculation attributes
    attribute :ignore_users_work_time, :boolean
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
    attribute :pull_request_exclude_rules, :string
    # slack notifications
    attribute :insights_webhook_url, :string
    # discord notifications
    attribute :insights_discord_webhook_url, :string
    # different
    enum :average_type, %i[arithmetic_mean median geometric_mean], default: :arithmetic_mean
    enum :main_attribute,
         %i[
           required_reviews_count
           comments_count
           reviews_count
           average_review_seconds
           review_involving
           reviewed_loc
           average_reviewed_loc
           open_pull_requests_count
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
