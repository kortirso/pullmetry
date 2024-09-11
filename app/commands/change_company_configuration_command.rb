# frozen_string_literal: true

class ChangeCompanyConfigurationCommand < BaseCommand
  use_contract do
    MainAttributes =
      Dry::Types['strict.string'].enum(*JsonbColumns::Configuration.main_attribute_values.keys.map(&:to_s))
    AverageTypes =
      Dry::Types['strict.string'].enum(*JsonbColumns::Configuration.average_type_values.keys.map(&:to_s))
    InsightRatioTypes =
      Dry::Types['strict.string'].enum(*JsonbColumns::Configuration.insight_ratio_type_values.keys.map(&:to_s))

    params do
      required(:company).filled(type?: Company)
      optional(:private).filled(:bool)
      optional(:insight_fields).value(:array, :filled?).each(included_in?: JsonbColumns::Insight.attribute_names)
      optional(:main_attribute).filled(MainAttributes)
      optional(:average_type).filled(AverageTypes)
      optional(:insight_ratio).filled(:bool)
      optional(:insight_ratio_type).filled(InsightRatioTypes)
    end
  end

  private

  def do_prepare(input)
    input[:insight_fields] = prepare_insight_fields(input[:insight_fields]) if input[:insight_fields]
  end

  def do_persist(input)
    ActiveRecord::Base.transaction do
      input[:company].configuration.assign_attributes(sliced_params(input))
      input[:company].save!
    end

    { result: input[:company].reload }
  end

  def prepare_insight_fields(insight_fields)
    insight_fields.index_with { true }
  end

  def sliced_params(input)
    params_list = %i[
      ignore_users_work_time private average_type fetch_period
      long_time_review_hours main_attribute
    ]
    # premium account has more available attributes for update
    if input[:company].premium?
      params_list.push(:insight_fields, :insight_ratio, :insight_ratio_type)
    end
    input.slice(*params_list)
  end
end
