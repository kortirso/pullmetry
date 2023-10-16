# frozen_string_literal: true

describe AdminDelivery, type: :delivery do
  let(:job) { double }

  describe '#published' do
    it 'delivers to slack_webhook' do
      expect {
        described_class.with(job: job).job_execution_report.deliver_later
      }.to deliver_via(:slack_webhook)
    end
  end
end
