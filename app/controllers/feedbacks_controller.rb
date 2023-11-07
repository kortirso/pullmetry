# frozen_string_literal: true

class FeedbacksController < ApplicationController
  include Deps[create_form: 'forms.feedbacks.create']

  def show
    @feedback = current_user.feedbacks.new
  end

  def create
    case create_form.call(user: current_user, params: feedback_params)
    in { errors: errors } then redirect_to feedback_path, alert: errors
    else redirect_to profile_path, alert: ['Thank you for your feedback']
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:title, :description)
  end
end
