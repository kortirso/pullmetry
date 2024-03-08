# frozen_string_literal: true

describe CompanyDelivery, type: :delivery do
  let!(:company) { create :company, accessable: false }

  before do
    create :webhook, source: Webhook::SLACK, url: 'url1', webhookable: company
    create :insight, insightable: company, reviews_count: 1
  end

  describe '#insights_report' do
    it 'does not deliver' do
      expect {
        described_class.with(insightable: company).insights_report.deliver_later
      }.not_to deliver_via(:webhook, :slack_webhook, :discord_webhook, :mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               enabled: true,
               source: Notification::SLACK,
               notification_type: Notification::INSIGHTS_DATA,
               notifyable: company
      end

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(insightable: company).insights_report.deliver_later
          }.to deliver_via(:slack_webhook)
        end
      end

      context 'with available discord webhook' do
        before do
          create :webhook, source: Webhook::DISCORD, url: 'url2', webhookable: company
          create :notification,
                 source: Notification::DISCORD,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).insights_report.deliver_later
          }.to deliver_via(:slack_webhook, :discord_webhook)
        end
      end

      context 'with available custom webhook' do
        before do
          create :webhook, source: Webhook::CUSTOM, url: 'url3', webhookable: company
          create :notification,
                 source: Notification::CUSTOM,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).insights_report.deliver_later
          }.to deliver_via(:slack_webhook, :webhook)
        end
      end

      context 'with available telegram webhook' do
        before do
          create :webhook, source: Webhook::TELEGRAM, url: 'url4', webhookable: company
          create :notification,
                 source: Notification::TELEGRAM,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).insights_report.deliver_later
          }.to deliver_via(:slack_webhook, :telegram)
        end
      end
    end
  end

  describe '#long_time_review_report' do
    let!(:repository) { create :repository, company: company }

    before { create :pull_request, repository: repository }

    it 'does not deliver' do
      expect {
        described_class.with(insightable: company).long_time_review_report.deliver_later
      }.not_to deliver_via(:webhook, :slack_webhook, :discord_webhook, :mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               enabled: true,
               source: Notification::SLACK,
               notification_type: Notification::LONG_TIME_REVIEW_DATA,
               notifyable: company
      end

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(insightable: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack_webhook)
        end
      end

      context 'with available discord webhook' do
        before do
          create :webhook, source: Webhook::DISCORD, url: 'url2', webhookable: company
          create :notification,
                 source: Notification::DISCORD,
                 notification_type: Notification::LONG_TIME_REVIEW_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack_webhook, :discord_webhook)
        end
      end

      context 'with available custom webhook' do
        before do
          create :webhook, source: Webhook::CUSTOM, url: 'url3', webhookable: company
          create :notification,
                 source: Notification::CUSTOM,
                 notification_type: Notification::LONG_TIME_REVIEW_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack_webhook, :webhook)
        end
      end

      context 'with available telegram webhook' do
        before do
          create :webhook, source: Webhook::TELEGRAM, url: 'url4', webhookable: company
          create :notification,
                 source: Notification::TELEGRAM,
                 notification_type: Notification::LONG_TIME_REVIEW_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack_webhook, :telegram)
        end
      end
    end
  end
end
