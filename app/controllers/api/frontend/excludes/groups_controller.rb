# frozen_string_literal: true

module Api
  module Frontend
    module Excludes
      class GroupsController < Api::FrontendController
        include Deps[add_excludes_group: 'commands.add_excludes_group']

        before_action :find_company, only: %i[create]
        before_action :find_excludes_group, only: %i[destroy]

        def create
          # commento: excludes_rules.target, excludes_rules.condition, excludes_rules.value
          case add_excludes_group.call({ company: @company, excludes_rules: create_excludes_rules_params })
          in { errors: errors } then render json: { errors: errors }, status: :ok
          in { result: result }
            render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
          end
        end

        def destroy
          authorize! @excludes_group.insightable, to: :update?
          @excludes_group.destroy
          render json: { result: :ok }, status: :ok
        end

        private

        def json_response(response, result)
          {
            result: response.serializer(
              result,
              ::Excludes::GroupSerializer,
              context: {
                rules: excludes_rules(result.id)
              }
            )
          }
        end

        def find_company
          @company = current_user.available_write_companies.find_by!(uuid: params[:company_id])
        end

        def find_excludes_group
          @excludes_group = ::Excludes::Group.find_by!(uuid: params[:id])
        end

        def excludes_rules(excludes_group_id)
          ::Excludes::Rule
            .where(excludes_group_id: excludes_group_id)
            .joins(:excludes_group)
            .hashable_pluck(:uuid, :target, :condition, :value, 'excludes_groups.uuid')
            .group_by { |rule| rule[:excludes_groups_uuid] }
        end

        def create_excludes_rules_params
          params.permit(excludes_rules: %i[target condition value])[:excludes_rules]
        end
      end
    end
  end
end
