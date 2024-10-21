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
        # find_excludes_groups
      end

      private

      def find_company
        @company = Company.find_by!(uuid: params[:company_id])
        @current_config = @company.current_config
      end

      def find_ignores
        @ignores = @company.ignores.hashable_pluck(:uuid, :entity_value)
      end

      def find_invites
        @accepted_invites = @company.companies_users.joins(:invite).hashable_pluck(:uuid, :access, 'invites.email')
        @invites = @company.invites.waiting.hashable_pluck(:uuid, :email, :access)
      end

      def find_notifications
        @notifications =
          @company.notifications.joins(:webhook).hashable_pluck(:uuid, :notification_type, 'webhooks.uuid')
      end

      def find_webhooks
        @webhooks = @company.webhooks.hashable_pluck(:uuid, :source, :url)
      end

      # def find_excludes_groups
      #   @excludes_groups =
      #     JSON.parse(
      #       Panko::ArraySerializer.new(
      #         @company.excludes_groups.order(id: :desc),
      #         each_serializer: Excludes::GroupSerializer,
      #         context: {
      #           rules: excludes_rules
      #         }
      #       ).to_json
      #     )
      # end

      # def excludes_rules
      #   Excludes::Rule
      #     .joins(:excludes_group)
      #     .where(excludes_groups: { insightable: @company })
      #     .hashable_pluck(:uuid, :target, :condition, :value, 'excludes_groups.uuid')
      #     .group_by { |rule| rule[:excludes_groups_uuid] }
      # end
    end
  end
end
