# frozen_string_literal: true

describe InsightDelivery, type: :delivery do
  let!(:company) { create :company }

  before { create :webhook, source: Webhook::SLACK, url: 'url1', insightable: company }

  describe '#report' do
    it 'does not deliver' do
      expect {
        described_class.with(insightable: company).report.deliver_later
      }.not_to deliver_via(:webhook, :slack_webhook, :discord_webhook, :mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               source: Notification::SLACK,
               notification_type: Notification::INSIGHTS_DATA,
               notifyable: company
      end

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(insightable: company).report.deliver_later
          }.to deliver_via(:slack_webhook)
        end
      end

      context 'with available discord webhook' do
        before do
          create :webhook, source: Webhook::DISCORD, url: 'url2', insightable: company
          create :notification,
                 source: Notification::DISCORD,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).report.deliver_later
          }.to deliver_via(:slack_webhook, :discord_webhook)
        end
      end

      context 'with available custom webhook' do
        before do
          create :webhook, source: Webhook::CUSTOM, url: 'url3', insightable: company
          create :notification,
                 source: Notification::CUSTOM,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).report.deliver_later
          }.to deliver_via(:slack_webhook, :webhook)
        end
      end
    end
  end
end
