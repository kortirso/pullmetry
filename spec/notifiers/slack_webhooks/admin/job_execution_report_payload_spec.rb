# frozen_string_literal: true

describe SlackWebhooks::Admin::JobExecutionReportPayload, type: :service do
  subject(:service_call) { described_class.new.call(job: job) }

  let(:job) { double }

  it 'succeeds' do
    expect(service_call[:blocks].size).to eq 1
  end
end
