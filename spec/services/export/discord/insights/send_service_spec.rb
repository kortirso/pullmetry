# frozen_string_literal: true

describe Export::Discord::Insights::SendService, type: :service do
  subject(:service_call) {
    described_class.new(payload_service: payload_service, send_service: send_service).call(insightable: insightable)
  }

  let!(:user) { create :user }
  let!(:insightable) { create :company, user: user }
  let(:payload_service) { double }
  let(:send_service) { double }
  let(:service_result) { double }
  let(:body) { { blocks: [] } }

  before do
    allow(payload_service).to receive(:call).and_return(service_result)
    allow(service_result).to receive(:result).and_return(body)

    allow(send_service).to receive(:send_message)
  end

  context 'for regular user' do
    it 'does not call services and succeeds', :aggregate_failures do
      service_call

      expect(payload_service).not_to have_received(:call)
      expect(send_service).not_to have_received(:send_message)
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for premium user' do
    before { user.subscriptions.create(start_time: 1.day.ago, end_time: 1.day.after) }

    context 'without webhook url' do
      it 'does not call services and succeeds', :aggregate_failures do
        service_call

        expect(payload_service).not_to have_received(:call)
        expect(send_service).not_to have_received(:send_message)
        expect(service_call.success?).to be_truthy
      end
    end

    context 'with webhook url' do
      before do
        insightable.configuration.insights_discord_webhook_url = 'url'
        insightable.save
      end

      it 'calls services and succeeds', :aggregate_failures do
        service_call

        expect(payload_service).to have_received(:call)
        expect(send_service).to have_received(:send_message)
        expect(service_call.success?).to be_truthy
      end
    end
  end
end
