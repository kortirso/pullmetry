# frozen_string_literal: true

module Export
  module Slack
    module Insights
      class PayloadService
        prepend ApplicationService

        def initialize(time_representer: Pullmetry::Container['services.converters.seconds_to_text'])
          @time_representer = time_representer
        end

        def call(insightable:)
          @insightable = insightable
          @result = {
            blocks: (header_block + accessable_message + insights_blocks + footer_block).compact
          }
        end

        private

        def header_block
          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*Pull review insights of #{@insightable.class.name.downcase} #{@insightable.title}*"
              }
            }
          ]
        end

        def accessable_message
          return [nil] if @insightable.accessable?

          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*#{@insightable.class.name} #{@insightable.title} has access error*"
              }
            }
          ]
        end

        def insights_blocks
          visible_insights.map { |insight|
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

        def visible_insights
          ::Insights::VisibleQuery
            .new(relation: @insightable.insights)
            .resolve(insightable: @insightable)
            .actual
            .joins(:entity)
            .hashable_pluck(
              :comments_count,
              :reviews_count,
              :average_review_seconds,
              'entities.login',
              'entities.avatar_url'
            )
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

        # rubocop: disable Layout/LineLength
        def insight_data(insight)
          average_time = @time_representer.call(value: insight[:average_review_seconds].to_i)
          {
            type: 'mrkdwn',
            text: "*Total comments:* #{insight[:comments_count].to_i}, *Total reviews:* #{insight[:reviews_count].to_i}, *Average review time:* #{average_time}"
          }
        end
        # rubocop: enable Layout/LineLength
      end
    end
  end
end
