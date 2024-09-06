# frozen_string_literal: true

module Frontend
  class VacationsController < Frontend::BaseController
    include Deps[add_vacation: 'commands.add_vacation']

    before_action :find_vacation, only: %i[destroy]

    def create
      # commento: vacations.start_time, vacations.end_time
      case add_vacation.call(vacation_params.merge(user: current_user))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      in { result: result }
        render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
      end
    end

    def destroy
      @vacation.destroy
      render json: { result: :ok }, status: :ok
    end

    private

    def json_response(response, result)
      {
        result: response.serializer(result, VacationSerializer)
      }
    end

    def find_vacation
      @vacation = current_user.vacations.find(params[:id])
    end

    def vacation_params
      params.require(:vacation).permit(:start_time, :end_time).to_h
    end
  end
end
