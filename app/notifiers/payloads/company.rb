# frozen_string_literal: true

module Payloads
  class Company
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
      when :insights_report then Reports::Company::Telegram::Insights.new.call(insightable: insightable)
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
      when :insights_report then Reports::Company::Discord::Insights.new.call(insightable: insightable)
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
      when :insights_report then Reports::Company::Slack::Insights.new.call(insightable: insightable)
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
      when :insights_report then Reports::Company::Custom::Insights.new.call(insightable: insightable)
      end
    end
  end
end
