# frozen_string_literal: true

describe Monitoring::Client do
  let(:client) { described_class.new }
  let(:provider) { Pullmetry::Container.resolve('monitoring.providers.bugsnag') }

  before { allow(provider).to receive(:notify) }

  describe 'notify' do
    it 'calls provider method' do
      client.notify(exception: 'Message')

      expect(provider).to have_received(:notify)
    end
  end
end
