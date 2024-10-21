# frozen_string_literal: true

module Frontend
  module Users
    class FeedbacksController < Frontend::BaseController
      include Deps[add_user_feedback: 'commands.add_user_feedback']

      def create
        case add_user_feedback.call(user_feedback_params.merge(user: current_user))
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: { status: 'ok' }, status: :created
        end
      end

      private

      def user_feedback_params
        params.require(:feedback).permit(:title, :description, :email, :answerable).to_h
      end
    end
  end
end
