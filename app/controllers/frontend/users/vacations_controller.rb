# frozen_string_literal: true

module Frontend
  module Users
    class VacationsController < Frontend::BaseController
      include Deps[add_user_vacation: 'commands.add_user_vacation']

      before_action :find_user_vacation, only: %i[destroy]

      def create
        case add_user_vacation.call(user_vacation_params.merge(user: current_user))
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
        end
      end

      def destroy
        @user_vacation.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def json_response(response, result)
        {
          result: response.serializer(result, User::VacationSerializer)
        }
      end

      def find_user_vacation
        @user_vacation = current_user.vacations.find(params[:id])
      end

      def user_vacation_params
        params.require(:user_vacation).permit(:start_time, :end_time).to_h
      end
    end
  end
end
