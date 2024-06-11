# frozen_string_literal: true

module Api
  module Frontend
    class FeedbacksController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.feedbacks.create']

      def create
        # commento: feedbacks.title, feedbacks.description, feedbacks.email, feedbacks.answerable
        case create_form.call(user: current_user, params: feedback_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: { status: 'ok' }, status: :ok
        end
      end

      private

      def feedback_params
        params.require(:feedback).permit(:title, :description, :email, :answerable)
      end
    end
  end
end
