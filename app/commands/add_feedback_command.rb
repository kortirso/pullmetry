# frozen_string_literal: true

class AddFeedbackCommand < BaseCommand
  use_contract do
    params do
      required(:user).filled(type?: User)
      required(:description).filled(:string)
      optional(:email)
    end
  end

  private

  def do_persist(input)
    feedback = Feedback.create!(input)

    AdminDelivery.with(id: feedback.id).feedback_created.deliver_later

    { result: feedback }
  end
end
