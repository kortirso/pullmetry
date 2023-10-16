# frozen_string_literal: true

describe SlackWebhooks::Admin::JobExecutionReportPayload, type: :service do
  subject(:service_call) { described_class.new.call(job_name: job_name) }

  let(:job_name) { 'Job::Name' }

  it 'succeeds' do
    expect(service_call[:blocks].size).to eq 1
  end
end
