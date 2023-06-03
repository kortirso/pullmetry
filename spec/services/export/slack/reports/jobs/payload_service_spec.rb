# frozen_string_literal: true

describe Export::Slack::Reports::Jobs::PayloadService, type: :service do
  subject(:service_call) { described_class.call(job: job) }

  let(:job) { double }

  it 'succeeds', :aggregate_failures do
    expect(service_call.success?).to be_truthy
    expect(service_call.result[:blocks].size).to eq 1
  end
end
