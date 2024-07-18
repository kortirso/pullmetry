# frozen_string_literal: true

module Payloads
  class Company
    include Deps[
      telegram_insights: 'reports.company.telegram.insights',
      telegram_repository_insights: 'reports.company.telegram.repository_insights',
      telegram_long_time_review: 'reports.company.telegram.long_time_review',
      telegram_no_new_pulls: 'reports.company.telegram.no_new_pulls',
      discord_insights: 'reports.company.discord.insights',
      discord_repository_insights: 'reports.company.discord.repository_insights',
      discord_long_time_review: 'reports.company.discord.long_time_review',
      discord_no_new_pulls: 'reports.company.discord.no_new_pulls',
      slack_insights: 'reports.company.slack.insights',
      slack_repository_insights: 'reports.company.slack.repository_insights',
      slack_long_time_review: 'reports.company.slack.long_time_review',
      slack_no_new_pulls: 'reports.company.slack.no_new_pulls',
      custom_insights: 'reports.company.custom.insights',
      custom_repository_insights: 'reports.company.custom.repository_insights',
      custom_long_time_review: 'reports.company.custom.long_time_review',
      custom_no_new_pulls: 'reports.company.custom.no_new_pulls',
    ]

    def call(notification_name:, notification:)
      company = notification.notifyable

      case notification.webhook.source
      when Webhook::TELEGRAM then telegram_payload(path(notification), company, notification_name)
      when Webhook::DISCORD then discord_payload(path(notification), company, notification_name)
      when Webhook::SLACK then slack_payload(path(notification), company, notification_name)
      when Webhook::CUSTOM then custom_payload(url(notification), company, notification_name)
      end
    end

    private

    def path(notification)
      URI(notification.webhook.url).path
    end

    def url(notification)
      URI(notification.webhook.url)
    end

    def telegram_payload(path, company, notification_name)
      {
        path: path,
        body: telegram_report(company, notification_name)
      }
    end

    def telegram_report(company, notification_name)
      case notification_name
      when :insights_report then telegram_insights.call(insightable: company)
      when :repository_insights_report then telegram_repository_insights.call(insightable: company)
      when :long_time_review_report then telegram_long_time_review.call(insightable: company)
      when :no_new_pulls_report then telegram_no_new_pulls.call(insightable: company)
      end
    end

    def discord_payload(path, company, notification_name)
      {
        path: path,
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
      when :no_new_pulls_report then discord_no_new_pulls.call(insightable: company)
      end
    end

    def slack_payload(path, company, notification_name)
      {
        path: path,
        body: slack_report(company, notification_name)
      }
    end

    def slack_report(company, notification_name)
      case notification_name
      when :insights_report then slack_insights.call(insightable: company)
      when :repository_insights_report then slack_repository_insights.call(insightable: company)
      when :long_time_review_report then slack_long_time_review.call(insightable: company)
      when :no_new_pulls_report then slack_no_new_pulls.call(insightable: company)
      end
    end

    def custom_payload(path, company, notification_name)
      {
        path: path,
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
      when :no_new_pulls_report then custom_no_new_pulls.call(insightable: company)
      end
    end
  end
end
