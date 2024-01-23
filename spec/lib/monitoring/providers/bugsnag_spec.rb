# frozen_string_literal: true

describe Monitoring::Providers::Bugsnag do
  let(:provider) { described_class.new }

  before { allow(Bugsnag).to receive(:notify) }

  describe 'notify' do
    context 'with info message' do
      subject(:provider_call) { provider.notify(exception: 'Message', metadata: { id: 1 }, severity: :info) }

      it 'sends notification' do
        provider_call

        expect(Bugsnag).to have_received(:notify)
      end
    end

    context 'with warning message' do
      subject(:provider_call) { provider.notify(exception: 'Message', metadata: { id: 1 }, severity: :warning) }

      it 'sends notification' do
        provider_call

        expect(Bugsnag).to have_received(:notify)
      end
    end
  end
end
