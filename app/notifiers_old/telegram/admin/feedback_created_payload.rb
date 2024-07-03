# frozen_string_literal: true

module Telegram
  module Admin
    class FeedbackCreatedPayload
      def call(id:)
        feedback = Feedback.find_by(id: id)

        "User - #{feedback.user_id}\nFeedback created - #{feedback.title}\n#{feedback.description}"
      end
    end
  end
end
