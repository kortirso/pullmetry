# frozen_string_literal: true

module Api
  module Frontend
    class VacationsController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.vacations.create']

      before_action :find_vacation, only: %i[destroy]

      def create
        # commento: vacations.start_time, vacations.end_time
        case create_form.call(user: current_user, params: vacation_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: { result: VacationSerializer.new(result).serializable_hash }, status: :ok
        end
      end

      def destroy
        @vacation.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_vacation
        @vacation = current_user.vacations.find(params[:id])
      end

      def vacation_params
        params.require(:vacation).permit(:start_time, :end_time)
      end
    end
  end
end
