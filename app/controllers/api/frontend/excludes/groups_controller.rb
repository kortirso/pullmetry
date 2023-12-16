# frozen_string_literal: true

module Api
  module Frontend
    module Excludes
      class GroupsController < Api::Frontend::BaseController
        include Deps[create_form: 'forms.excludes.groups.create']

        before_action :find_company, only: %i[create]
        before_action :find_excludes_group, only: %i[destroy]

        def create
          case create_form.call(company: @company)
          in { errors: errors } then render json: { errors: errors }, status: :ok
          in { result: result }
            render json: { result: ::Excludes::GroupSerializer.new(result).serializable_hash }, status: :ok
          end
        end

        def destroy
          authorize! @excludes_group.insightable, to: :update?
          @excludes_group.destroy
          render json: { result: :ok }, status: :ok
        end

        private

        def find_company
          @company = authorized_scope(Company.order(id: :desc)).find_by(uuid: params[:company_id])
          page_not_found if @company.nil?
        end

        def find_excludes_group
          @excludes_group = ::Excludes::Group.find_by(uuid: params[:id])
          page_not_found if @excludes_group.nil?
        end
      end
    end
  end
end
