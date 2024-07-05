# frozen_string_literal: true

class CompanyNotifier < AbstractNotifier::Base
  include Deps[company_payload: 'notifiers.payloads.company']

  def insights_report = report
  def repository_insights_report = report
  def long_time_review_report = report

  private

  def report
    notification(
      **company_payload.call(
        type: source,
        company: company,
        notification_name: notification_name,
        notifications: notifications
      )
    )
  end

  def company = params[:company]

  def notifications
    company
      .notifications
      .joins(:webhook)
      .where(notification_type: notification_type)
      .where(webhooks: { source: source })
  end

  def notification_type
    case notification_name
    when :insights_report then Notification::INSIGHTS_DATA
    when :repository_insights_report then Notification::REPOSITORY_INSIGHTS_DATA
    when :long_time_review_report then Notification::LONG_TIME_REVIEW_DATA
    end
  end
end
