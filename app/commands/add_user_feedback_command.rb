# frozen_string_literal: true

class AddUserFeedbackCommand < BaseCommand
  use_contract do
    params do
      required(:user).filled(type?: User)
      required(:description).filled(:string)
      optional(:answerable).filled(:bool)
      optional(:email)
    end
  end

  private

  def do_prepare(input)
    input.delete(:email) unless input[:answerable]
  end

  def do_persist(input)
    feedback = User::Feedback.create!(input)

    AdminDelivery.with(id: feedback.id).feedback_created.deliver_later

    { result: feedback }
  end
end
