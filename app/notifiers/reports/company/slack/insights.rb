# frozen_string_literal: true

module Reports
  module Company
    module Slack
      class Insights < Reports::Company::Insights
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          {
            blocks: (
              header_block(insightable) +
                accessable_block(insightable) +
                insights_blocks(insightable) +
                footer_block
            ).compact
          }
        end

        private

        def header_block(insightable)
          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*#{title(insightable)}*"
              }
            }
          ]
        end

        def accessable_block(insightable)
          message = accessable_message(insightable)
          return [nil] if message.blank?

          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*#{message}*"
              }
            }
          ]
        end

        def insights_blocks(insightable)
          visible_insights(insightable).map { |insight|
            {
              type: 'context',
              elements: [
                avatar_element(insight[:entities_avatar_url]),
                login_element(insight[:entities_login]),
                insight_data(insight)
              ]
            }
          }
        end

        def insight_data(insight)
          {
            type: 'context',
            elements: [
              avatar_element(insight[:entities_avatar_url]),
              login_element(insight[:entities_login]),
              insight_element(insight)
            ]
          }
        end

        def avatar_element(value)
          {
            type: 'image',
            image_url: value,
            alt_text: 'avatar'
          }
        end

        def login_element(value)
          {
            type: 'plain_text',
            text: value,
            emoji: true
          }
        end

        def insight_element(insight)
          average_time = time_representer.call(value: insight[:average_review_seconds].to_i)
          {
            type: 'mrkdwn',
            text: [
              "*Total comments:* #{insight[:comments_count].to_i}",
              "*Total reviews:* #{insight[:reviews_count].to_i}",
              "*Average review time:* #{average_time}"
            ].join(', ')
          }
        end

        def footer_block
          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: 'To check up-to-date statistics please visit <https://pullkeeper.dev|PullKeeper>'
              }
            }
          ]
        end
      end
    end
  end
end
