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

    def call(type:, company:, notification_name:, notifications:)
      case type
      when Webhook::TELEGRAM then telegram_payload(paths(notifications), company, notification_name)
      when Webhook::DISCORD then discord_payload(paths(notifications), company, notification_name)
      when Webhook::SLACK then slack_payload(paths(notifications), company, notification_name)
      when Webhook::CUSTOM then custom_payload(urls(notifications), company, notification_name)
      end
    end

    private

    def paths(notifications)
      notifications.map { |notification| URI(notification.webhook.url).path }
    end

    def urls(notifications)
      notifications.map { |notification| URI(notification.webhook.url) }
    end

    def telegram_payload(paths, company, notification_name)
      {
        paths: paths,
        body: telegram_report(company, notification_name)
      }
    end

    def telegram_report(company, notification_name)
      case notification_name
      when :insights_report then telegram_insights.call(insightable: company)
      when :repository_insights_report then telegram_repository_insights.call(insightable: company)
      when :long_time_review_report then telegram_long_time_review.call(insightable: company)
      end
    end

    def discord_payload(paths, company, notification_name)
      {
        paths: paths,
        body: {
          username: 'PullKeeper',
          content: discord_report(company, notification_name)
        }
      }
    end

    def discord_report(company, notification_name)
      case notification_name
      when :insights_report then discord_insights.call(insightable: company)
      when :repository_insights_report then discord_repository_insights.call(insightable: company)
      when :long_time_review_report then discord_long_time_review.call(insightable: company)
      end
    end

    def slack_payload(paths, company, notification_name)
      {
        paths: paths,
        body: slack_report(company, notification_name)
      }
    end

    def slack_report(company, notification_name)
      case notification_name
      when :insights_report then slack_insights.call(insightable: company)
      when :repository_insights_report then slack_repository_insights.call(insightable: company)
      when :long_time_review_report then slack_long_time_review.call(insightable: company)
      end
    end

    def custom_payload(paths, company, notification_name)
      {
        paths: paths,
        body: {
          content: custom_report(company, notification_name)
        }
      }
    end

    def custom_report(company, notification_name)
      case notification_name
      when :insights_report then custom_insights.call(insightable: company)
      when :repository_insights_report then custom_repository_insights.call(insightable: company)
      when :long_time_review_report then custom_long_time_review.call(insightable: company)
      end
    end
  end
end
