# frozen_string_literal: true

describe CompanyDelivery, type: :delivery do
  let!(:company) { create :company, accessable: false }
  let!(:webhook) { create :webhook, source: Webhook::SLACK, url: 'url1', company: company }

  before do
    create :insight, insightable: company, reviews_count: 1
  end

  describe '#insights_report' do
    it 'does not deliver' do
      expect {
        described_class.with(company: company).insights_report.deliver_later
      }.not_to deliver_via(:webhook, :slack, :discord, :mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               notification_type: Notification::INSIGHTS_DATA,
               notifyable: company,
               webhook: webhook
      end

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(company: company).insights_report.deliver_later
          }.to deliver_via(:slack)
        end
      end

      context 'with available discord webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::DISCORD, url: 'url2', company: company
          create :notification,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).insights_report.deliver_later
          }.to deliver_via(:slack, :discord)
        end
      end

      context 'with available custom webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::CUSTOM, url: 'url3', company: company
          create :notification,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).insights_report.deliver_later
          }.to deliver_via(:slack, :webhook)
        end
      end

      context 'with available telegram webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::TELEGRAM, url: 'url4', company: company
          create :notification,
                 notification_type: Notification::INSIGHTS_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).insights_report.deliver_later
          }.to deliver_via(:slack, :telegram)
        end
      end
    end
  end

  describe '#repository_insights_report' do
    it 'does not deliver' do
      expect {
        described_class.with(company: company).repository_insights_report.deliver_later
      }.not_to deliver_via(:webhook, :slack, :discord, :mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               notification_type: Notification::REPOSITORY_INSIGHTS_DATA,
               notifyable: company,
               webhook: webhook
      end

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(company: company).repository_insights_report.deliver_later
          }.to deliver_via(:slack)
        end
      end

      context 'with available discord webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::DISCORD, url: 'url2', company: company
          create :notification,
                 notification_type: Notification::REPOSITORY_INSIGHTS_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).repository_insights_report.deliver_later
          }.to deliver_via(:slack, :discord)
        end
      end

      context 'with available custom webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::CUSTOM, url: 'url3', company: company
          create :notification,
                 notification_type: Notification::REPOSITORY_INSIGHTS_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).repository_insights_report.deliver_later
          }.to deliver_via(:slack, :webhook)
        end
      end

      context 'with available telegram webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::TELEGRAM, url: 'url4', company: company
          create :notification,
                 notification_type: Notification::REPOSITORY_INSIGHTS_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).repository_insights_report.deliver_later
          }.to deliver_via(:slack, :telegram)
        end
      end
    end
  end

  describe '#long_time_review_report' do
    let!(:repository) { create :repository, company: company }

    before { create :pull_request, repository: repository }

    it 'does not deliver' do
      expect {
        described_class.with(company: company).long_time_review_report.deliver_later
      }.not_to deliver_via(:webhook, :slack, :discord, :mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               notification_type: Notification::LONG_TIME_REVIEW_DATA,
               notifyable: company,
               webhook: webhook
      end

      context 'with only available slack webhook' do
        it 'delivers to slack_webhook' do
          expect {
            described_class.with(company: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack)
        end
      end

      context 'with available discord webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::DISCORD, url: 'url2', company: company
          create :notification,
                 notification_type: Notification::LONG_TIME_REVIEW_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack, :discord)
        end
      end

      context 'with available custom webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::CUSTOM, url: 'url3', company: company
          create :notification,
                 notification_type: Notification::LONG_TIME_REVIEW_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack, :webhook)
        end
      end

      context 'with available telegram webhook' do
        before do
          another_webhook = create :webhook, source: Webhook::TELEGRAM, url: 'url4', company: company
          create :notification,
                 notification_type: Notification::LONG_TIME_REVIEW_DATA,
                 notifyable: company,
                 webhook: another_webhook
        end

        it 'delivers to 2 webhooks' do
          expect {
            described_class.with(company: company).long_time_review_report.deliver_later
          }.to deliver_via(:slack, :telegram)
        end
      end
    end
  end
end
