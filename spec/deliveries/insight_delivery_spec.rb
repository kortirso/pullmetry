# frozen_string_literal: true

describe InsightDelivery, type: :delivery do
  let!(:company) { create :company }

  before { create :webhook, source: 'slack', url: 'url1', insightable: company }

  describe '#report' do
    context 'for regular account' do
      it 'does not deliver' do
        expect {
          described_class.with(insightable: company).report.deliver_later
        }.not_to deliver_via(:slack_webhook, :discord_webhook, :mailer)
      end
    end

    context 'for premium account' do
      before { create :subscription, user: company.user }

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(insightable: company).report.deliver_later
          }.to deliver_via(:slack_webhook)
        end
      end

      context 'with available discord webhook' do
        before { create :webhook, source: 'discord', url: 'url2', insightable: company }

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(insightable: company).report.deliver_later
          }.to deliver_via(:slack_webhook, :discord_webhook)
        end
      end
    end
  end
end
