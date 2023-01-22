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
    # TODO: configuration field for repository
    # attribute :start_from_pull_number, :integer
  end
end
