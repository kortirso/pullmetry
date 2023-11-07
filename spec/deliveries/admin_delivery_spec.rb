# frozen_string_literal: true

describe AdminDelivery, type: :delivery do
  let(:job) { double }

  describe '#job_execution_report' do
    before do
      allow(Pullmetry::Application).to(
        receive(:credentials).and_return({ reports_webhook_url: 'https://hooks.slack.com/services/T0/B0/G0' })
      )
    end

    it 'delivers to slack_webhook', skip: 'GA does not recognize credentials' do
      expect {
        described_class.with(job_name: job.class.name).job_execution_report.deliver_later
      }.to deliver_via(:slack_webhook)
    end
  end

  describe '#feedback_created' do
    let!(:feedback) { create :feedback }

    before do
      allow(Pullmetry::Application).to(
        receive(:credentials).and_return({ reports_webhook_url: 'https://hooks.slack.com/services/T0/B0/G0' })
      )
    end

    it 'delivers to slack_webhook', skip: 'GA does not recognize credentials' do
      expect {
        described_class.with(id: feedback.id).feedback_created.deliver_later
      }.to deliver_via(:slack_webhook)
    end
  end
end
