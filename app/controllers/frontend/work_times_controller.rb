# frozen_string_literal: true

module Frontend
  class WorkTimesController < Frontend::BaseController
    include Deps[change_work_time: 'commands.change_work_time']

    def create
      # commento: work_times.starts_at, work_times.ends_at, work_times.timezone
      case change_work_time.call(work_time_params.merge(worktimeable: worktimeable))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      else render json: {}, status: :created
      end
    end

    private

    def worktimeable
      return find_company if params[:company_id]

      current_user
    end

    def find_company
      current_user.available_write_companies.find_by!(uuid: params[:company_id])
    end

    def work_time_params
      params.permit(:timezone, :starts_at, :ends_at).to_h
    end
  end
end
