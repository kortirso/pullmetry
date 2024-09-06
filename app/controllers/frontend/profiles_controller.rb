# frozen_string_literal: true

module Frontend
  class ProfilesController < Frontend::BaseController
    include Deps[change_user: 'commands.change_user']

    def update
      # commento: users.start_time, users.end_time, users.time_zone
      case change_user.call(user_params.merge(user: current_user))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      else render json: { redirect_path: profile_path }, status: :ok
      end
    end

    private

    def user_params
      params.require(:user).permit(:time_zone, :start_time, :end_time).to_h
    end
  end
end
