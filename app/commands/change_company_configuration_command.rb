# frozen_string_literal: true

class ChangeCompanyConfigurationCommand < BaseCommand
  use_contract do
    params do
      required(:company).filled(type?: Company)
      optional(:private).filled(:bool)
    end
  end

  private

  def do_persist(input)
    ActiveRecord::Base.transaction do
      input[:company].configuration.assign_attributes(sliced_params(input))
      input[:company].save!
    end

    { result: input[:company].reload }
  end

  def sliced_params(input)
    params_list = %i[
      ignore_users_work_time work_time_zone work_start_time work_end_time private average_type fetch_period
      long_time_review_hours
    ]
    # premium account has more available attributes for update
    if input[:company].premium?
      params_list.push(:insight_fields, :insight_ratio, :insight_ratio_type, :main_attribute)
    end
    input.slice(*params_list)
  end
end
