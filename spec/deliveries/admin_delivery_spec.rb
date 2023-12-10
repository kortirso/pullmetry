# frozen_string_literal: true

describe AdminDelivery, type: :delivery do
  let(:job) { double }

  before do
    allow(Rails.application.credentials).to(
      receive(:[]).with(:reports_telegram_chat_id).and_return('id')
    )
  end

  describe '#job_execution_report' do
    it 'delivers to telegram' do
      expect {
        described_class.with(job_name: job.class.name).job_execution_report.deliver_later
      }.to deliver_via(:telegram)
    end
  end

  describe '#feedback_created' do
    let!(:feedback) { create :feedback }

    it 'delivers to telegram' do
      expect {
        described_class.with(id: feedback.id).feedback_created.deliver_later
      }.to deliver_via(:telegram)
    end
  end
end
