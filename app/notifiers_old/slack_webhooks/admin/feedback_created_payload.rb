# frozen_string_literal: true

module SlackWebhooks
  module Admin
    class FeedbackCreatedPayload
      def call(id:)
        feedback = Feedback.find_by(id: id)

        {
          blocks: (
            user_block(feedback.user_id) + header_block(feedback.title) + text_block(feedback.description)
          ).compact
        }
      end

      private

      def user_block(user_id)
        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "*User - #{user_id}*"
            }
          }
        ]
      end

      def header_block(title)
        return [nil] if title.nil?

        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "*Feedback created - #{title}*"
            }
          }
        ]
      end

      def text_block(description)
        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: description
            }
          }
        ]
      end
    end
  end
end
