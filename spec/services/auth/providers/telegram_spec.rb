# frozen_string_literal: true

describe Auth::Providers::Telegram do
  subject(:service_call) { instance.call(params: params) }

  let(:instance) { described_class.new }
  let(:valid_payload) {
    {
      id: 'id',
      auth_date: 1.hour.ago.to_i,
      first_name: 'First',
      last_name: 'Last',
      photo_url: 'photo_url',
      username: 'username'
    }
  }
  let(:expired_payload) {
    {
      id: 'id',
      auth_date: 2.weeks.ago.to_i,
      first_name: 'First',
      last_name: 'Last',
      photo_url: 'photo_url',
      username: 'username'
    }
  }
  let(:valid_hash) { instance.send(:calculate_signature, valid_payload) }
  let(:expired_hash) { instance.send(:calculate_signature, expired_payload) }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_return('secret')
  end

  context 'for invalid params' do
    let(:params) { { id: 'id' } }

    it 'returns nil result', :aggregate_failures do
      expect(service_call[:result]).to be_nil
      expect(service_call[:errors]).to eq(['Required field is missing'])
    end
  end

  context 'for signature mismatch' do
    let(:params) { valid_payload.merge(hash: 'invalid-hash') }

    it 'returns nil result', :aggregate_failures do
      expect(service_call[:result]).to be_nil
      expect(service_call[:errors]).to eq(['Signature mismatch'])
    end
  end

  context 'for expired session' do
    let(:params) { expired_payload.merge(hash: expired_hash) }

    it 'returns nil result', :aggregate_failures do
      expect(service_call[:result]).to be_nil
      expect(service_call[:errors]).to eq(['Session expired'])
    end
  end

  context 'for valid data' do
    let(:params) { valid_payload.merge(hash: valid_hash) }

    it 'returns result', :aggregate_failures do
      expect(service_call[:errors]).to be_blank
      expect(service_call[:result]).to eq({
        uid: 'id',
        provider: Providerable::TELEGRAM,
        login: 'username'
      })
    end
  end
end
