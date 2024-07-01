# frozen_string_literal: true

module Companies
  class ConfigurationsController < ApplicationController
    include Deps[
      update_form: 'forms.companies.configurations.update',
      to_bool: 'to_bool'
    ]

    before_action :find_company

    def edit
      find_ignores
      find_invites
      find_notifications
      find_webhooks
      find_excludes_groups
      find_insight_ratio_type_values
      find_average_type_values
      find_main_attribute_values
    end

    def update
      # commento: companies.configuration
      case update_form.call(company: @company, params: configuration_params, use_work_time: use_work_time)
      in { errors: errors } then redirect_to edit_company_configuration_path(@company.uuid), alert: errors
      else redirect_to companies_path
      end
    end

    private

    def find_company
      @company = current_user.companies.find_by!(uuid: params[:company_id])
    end

    def find_ignores
      @ignores = @company.ignores.hashable_pluck(:uuid, :entity_value)
    end

    def find_invites
      @accepted_invites = @company.companies_users.joins(:invite).hashable_pluck(:uuid, :access, 'invites.email')
      @invites = @company.invites.waiting.hashable_pluck(:uuid, :email, :access)
    end

    def find_notifications
      @notifications = @company.notifications.hashable_pluck(:id, :uuid, :source, :notification_type)
    end

    def find_webhooks
      @webhooks =
        Webhook.where(webhookable: @company)
          .or(
            Webhook.where(webhookable_id: @notifications.pluck(:id), webhookable_type: 'Notification')
          )
          .hashable_pluck(:uuid, :source, :url, :webhookable_id, :webhookable_type)
          .map { |webhook|
            next webhook if webhook[:webhookable_type] == 'Company'

            webhook.merge(
              webhookable_uuid: @notifications.find { |element| element[:id] == webhook[:webhookable_id] }[:uuid]
            )
          }
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
          :long_time_review_hours,
          insight_fields: {}
        )
    end

    def use_work_time
      to_bool.call(params[:jsonb_columns_configuration][:use_work_time])
    end
  end
end
