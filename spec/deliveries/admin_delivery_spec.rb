# frozen_string_literal: true

describe AdminDelivery, type: :delivery do
  let(:job) { double }

  before do
    allow(Rails.application.credentials).to(
      receive(:[]).with(:reports_webhook_url).and_return('https://hooks.slack.com/services/T0/B0/G0')
    )
  end

  describe '#job_execution_report' do
    it 'delivers to slack_webhook' do
      expect {
        described_class.with(job_name: job.class.name).job_execution_report.deliver_later
      }.to deliver_via(:slack_webhook)
    end
  end

  describe '#feedback_created' do
    let!(:feedback) { create :feedback }

    it 'delivers to slack_webhook' do
      expect {
        described_class.with(id: feedback.id).feedback_created.deliver_later
      }.to deliver_via(:slack_webhook)
    end
  end
end
