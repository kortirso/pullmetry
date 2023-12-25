# frozen_string_literal: true

module Companies
  class ConfigurationsController < ApplicationController
    include Boolable

    before_action :find_company

    def edit
      find_ignores
      find_webhooks
      find_notifications
      find_excludes_groups
      find_insight_ratio_type_values
      find_average_type_values
      find_main_attribute_values
    end

    def update
      # commento: companies.configuration
      form = Companies::Configurations::UpdateForm.call(
        company: @company,
        params: configuration_params,
        use_work_time: to_bool(params[:jsonb_columns_configuration][:use_work_time])
      )
      if form.success?
        redirect_to companies_path
      else
        redirect_to edit_company_configuration_path(@company.uuid), alert: form.errors
      end
    end

    private

    def find_company
      @company = current_user.companies.find_by!(uuid: params[:company_id])
    end

    def find_ignores
      @ignores = @company.ignores.hashable_pluck(:uuid, :entity_value)
    end

    def find_webhooks
      @webhooks = @company.webhooks.hashable_pluck(:uuid, :source, :url)
    end

    def find_notifications
      @notifications = @company.notifications.hashable_pluck(:source, :notification_type)
    end

    def find_excludes_groups
      @excludes_groups =
        Excludes::GroupSerializer.new(
          @company.excludes_groups.order(id: :desc),
          params: { rules: excludes_rules }
        ).serializable_hash
    end

    def excludes_rules
      Excludes::Rule
        .joins(:excludes_group)
        .where(excludes_groups: { insightable: @company })
        .hashable_pluck(:uuid, :target, :condition, :value, 'excludes_groups.uuid')
        .group_by { |rule| rule[:excludes_groups_uuid] }
    end

    def find_insight_ratio_type_values
      @insight_ratio_type_values = @company.configuration.insight_ratio_type_values.map { |key, _v| transform_key(key) }
    end

    def find_average_type_values
      @average_type_values = @company.configuration.average_type_values.map { |key, _v| transform_key(key) }
    end

    def find_main_attribute_values
      @main_attribute_values = @company.configuration.main_attribute_values.map { |key, _v| transform_key(key) }
    end

    def transform_key(key)
      [key.to_s.capitalize.split('_').join(' '), key]
    end

    def configuration_params
      params
        .require(:jsonb_columns_configuration)
        .permit(
          :private,
          :insight_ratio,
          :insight_ratio_type,
          :ignore_users_work_time,
          :work_time_zone,
          :work_start_time,
          :work_end_time,
          :average_type,
          :main_attribute,
          :fetch_period,
          insight_fields: {}
        )
    end
  end
end
