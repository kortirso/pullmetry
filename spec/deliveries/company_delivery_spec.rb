# frozen_string_literal: true

describe CompanyDelivery, type: :delivery do
  let!(:company) { create :company, accessable: false }
  let!(:webhook) { create :webhook, source: Webhook::SLACK, url: 'url1', company: company }

  before do
    create :insight, insightable: company, reviews_count: 1
  end

  describe '#insights_report' do
    let!(:notification) {
      create :notification,
             notification_type: Notification::INSIGHTS_DATA,
             notifyable: company,
             webhook: webhook
    }

    it 'delivers to slack_webhook' do
      expect {
        described_class.with(notification: notification).insights_report.deliver_later
      }.to deliver_via(:slack)
    end
  end

  describe '#repository_insights_report' do
    let!(:notification) {
      create :notification,
             notification_type: Notification::REPOSITORY_INSIGHTS_DATA,
             notifyable: company,
             webhook: webhook
    }

    it 'delivers to slack_webhook' do
      expect {
        described_class.with(notification: notification).repository_insights_report.deliver_later
      }.to deliver_via(:slack)
    end
  end

  describe '#long_time_review_report' do
    let!(:notification) {
      create :notification,
             notification_type: Notification::LONG_TIME_REVIEW_DATA,
             notifyable: company,
             webhook: webhook
    }

    it 'delivers to slack_webhook' do
      expect {
        described_class.with(notification: notification).long_time_review_report.deliver_later
      }.to deliver_via(:slack)
    end
  end

  describe '#no_new_pulls_report' do
    let!(:notification) {
      create :notification,
             notification_type: Notification::NO_NEW_PULLS_DATA,
             notifyable: company,
             webhook: webhook
    }

    it 'delivers to slack_webhook' do
      expect {
        described_class.with(notification: notification).no_new_pulls_report.deliver_later
      }.to deliver_via(:slack)
    end
  end
end
