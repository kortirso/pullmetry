# frozen_string_literal: true

describe Export::Slack::Reports::Jobs::SendService, type: :service do
  subject(:service_call) {
    described_class.new(payload_service: payload_service, send_service: send_service).call(job: job)
  }

  let!(:job) { double }
  let(:payload_service) { double }
  let(:send_service) { double }
  let(:service_result) { double }
  let(:body) { { blocks: [] } }

  before do
    allow(payload_service).to receive(:call).and_return(service_result)
    allow(service_result).to receive(:result).and_return(body)

    allow(send_service).to receive(:send_message)
  end

  it 'calls services and succeeds', :aggregate_failures do
    service_call

    expect(payload_service).to have_received(:call)
    expect(send_service).to have_received(:send_message)
    expect(service_call.success?).to be_truthy
  end
end
