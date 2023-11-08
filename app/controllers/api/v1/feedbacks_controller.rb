# frozen_string_literal: true

module Api
  module V1
    class FeedbacksController < ApplicationController
      include Deps[create_form: 'forms.feedbacks.create']

      def create
        # commento: feedback.title, feedbacks.description
        case create_form.call(user: current_user, params: feedback_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: { status: 'ok' }, status: :ok
        end
      end

      private

      def feedback_params
        params.require(:feedback).permit(:title, :description)
      end
    end
  end
end
