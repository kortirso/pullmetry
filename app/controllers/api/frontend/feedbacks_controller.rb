# frozen_string_literal: true

module Api
  module Frontend
    class FeedbacksController < Api::Frontend::BaseController
      include Deps[add_feedback: 'commands.add_feedback']

      def create
        # commento: feedbacks.title, feedbacks.description, feedbacks.email, feedbacks.answerable
        case add_feedback.call(feedback_params.merge(user: current_user))
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: { status: 'ok' }, status: :ok
        end
      end

      private

      def feedback_params
        params.require(:feedback).permit(:title, :description, :email, :answerable).to_h
      end
    end
  end
end
