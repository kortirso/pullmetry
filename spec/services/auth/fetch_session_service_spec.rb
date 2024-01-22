# frozen_string_literal: true

describe Auth::FetchSessionService do
  subject(:service_call) { instance.call(token: token) }

  let!(:instance) { described_class.new }

  context 'for valid token' do
    let(:token) { JwtEncoder.new.encode(payload: { uuid: session_uuid }) }

    context 'for unexisted session' do
      let(:session_uuid) { 'random uuid' }

      it 'does not assign user and fails', :aggregate_failures do
        expect(service_call[:result]).to be_nil
        expect(service_call[:errors]).not_to be_blank
      end
    end

    context 'for existed session' do
      let(:users_session) { create :users_session }
      let(:session_uuid) { users_session.uuid }

      it 'assigns user and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq users_session
        expect(service_call[:errors]).to be_blank
      end
    end
  end

  context 'for invalid token' do
    let(:token) { 'random uuid' }

    it 'does not assign user and fails', :aggregate_failures do
      expect(service_call[:result]).to be_nil
      expect(service_call[:errors]).not_to be_blank
    end
  end
end
