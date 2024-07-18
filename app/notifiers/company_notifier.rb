# frozen_string_literal: true

class CompanyNotifier < AbstractNotifier::Base
  include Deps[company_payload: 'notifiers.payloads.company']

  def insights_report = report
  def repository_insights_report = report
  def long_time_review_report = report
  def no_new_pulls_report = report

  private

  def report
    notification(
      **company_payload.call(
        notification_name: notification_name,
        notification: params[:notification]
      )
    )
  end
end
