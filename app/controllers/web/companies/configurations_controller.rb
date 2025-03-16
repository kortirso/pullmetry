# frozen_string_literal: true

module Web
  module Companies
    class ConfigurationsController < ApplicationController
      before_action :find_company

      def edit
        authorize! @company

        find_ignores
        find_invites
        find_notifications
        find_webhooks
        find_excludes_groups
      end

      private

      def find_company
        @company = Company.find(params[:company_id])
        @current_config = @company.current_config
      end

      def find_ignores
        @ignores = @company.entity_ignores.hashable_pluck(:id, :entity_value)
      end

      def find_invites
        @accepted_invites = @company.companies_users.joins(:invite).hashable_pluck(:id, :access, 'invites.email')
        @invites = @company.invites.waiting.hashable_pluck(:id, :email, :access)
      end

      def find_notifications
        @notifications = @company.notifications.hashable_pluck(:id, :notification_type, :webhook_id)
      end

      def find_webhooks
        @webhooks = @company.webhooks.hashable_pluck(:id, :source, :url)
      end

      def find_excludes_groups
        @excludes_groups =
          JSON.parse(
            Panko::ArraySerializer.new(
              @company.excludes_groups.order(created_at: :desc),
              each_serializer: Excludes::GroupSerializer,
              context: {
                rules: excludes_rules
              }
            ).to_json
          )
      end

      def excludes_rules
        Excludes::Rule
          .joins(:excludes_group)
          .where(excludes_groups: { insightable: @company })
          .hashable_pluck(:id, :target, :condition, :value, :excludes_group_id)
          .group_by { |rule| rule[:excludes_group_id] }
      end
    end
  end
end
