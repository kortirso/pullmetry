# frozen_string_literal: true

module Payloads
  class Company
    include Deps[
      telegram_insights: 'reports.company.telegram.insights',
      telegram_repository_insights: 'reports.company.telegram.repository_insights',
      telegram_long_time_review: 'reports.company.telegram.long_time_review',
      discord_insights: 'reports.company.discord.insights',
      discord_repository_insights: 'reports.company.discord.repository_insights',
      discord_long_time_review: 'reports.company.discord.long_time_review',
      slack_insights: 'reports.company.slack.insights',
      slack_repository_insights: 'reports.company.slack.repository_insights',
      slack_long_time_review: 'reports.company.slack.long_time_review',
      custom_insights: 'reports.company.custom.insights',
      custom_repository_insights: 'reports.company.custom.repository_insights',
      custom_long_time_review: 'reports.company.custom.long_time_review',
    ]

    def call(type:, path:, url:, insightable:, notification_name:)
      case type
      when Notification::TELEGRAM then telegram_payload(path, insightable, notification_name)
      when Notification::DISCORD then discord_payload(path, insightable, notification_name)
      when Notification::SLACK then slack_payload(path, insightable, notification_name)
      when Notification::CUSTOM then custom_payload(url.path, insightable, notification_name)
      end
    end

    private

    def telegram_payload(path, insightable, notification_name)
      {
        chat_id: path,
        body: telegram_report(insightable, notification_name)
      }
    end

    def telegram_report(insightable, notification_name)
      case notification_name
      when :insights_report then telegram_insights.call(insightable: insightable)
      when :repository_insights_report then telegram_repository_insights.call(insightable: insightable)
      when :long_time_review_report then telegram_long_time_review.call(insightable: insightable)
      end
    end

    def discord_payload(path, insightable, notification_name)
      {
        path: path,
        body: {
          username: 'PullKeeper',
          content: discord_report(insightable, notification_name)
        }
      }
    end

    def discord_report(insightable, notification_name)
      case notification_name
      when :insights_report then discord_insights.call(insightable: insightable)
      when :repository_insights_report then discord_repository_insights.call(insightable: insightable)
      when :long_time_review_report then discord_long_time_review.call(insightable: insightable)
      end
    end

    def slack_payload(path, insightable, notification_name)
      {
        path: path,
        body: slack_report(insightable, notification_name)
      }
    end

    def slack_report(insightable, notification_name)
      case notification_name
      when :insights_report then slack_insights.call(insightable: insightable)
      when :repository_insights_report then slack_repository_insights.call(insightable: insightable)
      when :long_time_review_report then slack_long_time_review.call(insightable: insightable)
      end
    end

    def custom_payload(path, insightable, notification_name)
      {
        path: path,
        body: {
          content: custom_report(insightable, notification_name)
        }
      }
    end

    def custom_report(insightable, notification_name)
      case notification_name
      when :insights_report then custom_insights.call(insightable: insightable)
      when :repository_insights_report then custom_repository_insights.call(insightable: insightable)
      when :long_time_review_report then custom_long_time_review.call(insightable: insightable)
      end
    end
  end
end
