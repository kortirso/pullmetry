# frozen_string_literal: true

module Configurable
  extend ActiveSupport::Concern

  included do
    attribute :config, Company::Config.to_type
  end

  # current_config returns actual config for premium account
  # for regular account - actual config with only specific regular attributes (restricted values replaced with default values)
  def current_config
    return config if premium?

    params_list = %w[ignore_users_work_time private average_type long_time_review_hours main_attribute]
    fetch_period = config.fetch_period ? [config.fetch_period, Insight::FETCH_DAYS_PERIOD].min : Insight::FETCH_DAYS_PERIOD
    Company::Config.new(config.as_json.slice(*params_list).merge('fetch_period' => fetch_period))
  end
end
