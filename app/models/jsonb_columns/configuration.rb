# frozen_string_literal: true

module JsonbColumns
  class Configuration
    include StoreModel::Model

    # insights calculation attributes
    attribute :work_start_time, :datetime
    attribute :work_end_time, :datetime
    # insights table view attributes
    attribute :insight_fields, JsonbColumns::Insight.to_type
    attribute :insight_ratio, :boolean
    attribute :rows_limit, :integer
    # data fetching attributes
    attribute :fetch_period, :integer
    # slack notifications
    attribute :insights_webhook_url, :string
    # different
    enum :average_type, %i[arithmetic_mean median], default: :arithmetic_mean
    enum :main_attribute,
         %i[
           comments_count
           reviews_count
           required_reviews_count
           open_pull_requests_count
           average_review_seconds
           average_merge_seconds
         ],
         default: :comments_count
    # TODO: configuration field for repository
    # attribute :start_from_pull_number, :integer
  end
end
