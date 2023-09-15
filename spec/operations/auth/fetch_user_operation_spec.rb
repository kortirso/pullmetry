# frozen_string_literal: true

describe Auth::FetchUserOperation do
  subject(:service_call) { described_class.call(token: token) }

  context 'for valid token' do
    let(:token) { JwtEncoder.encode(uuid: session_uuid) }

    context 'for unexisted session' do
      let(:session_uuid) { 'random uuid' }

      it 'does not assign user and fails', :aggregate_failures do
        expect(service_call.result).to be_nil
        expect(service_call.failure?).to be_truthy
      end
    end

    context 'for existed session' do
      let(:users_session) { create :users_session }
      let(:session_uuid) { users_session.uuid }

      it 'assigns user and succeeds', :aggregate_failures do
        expect(service_call.result).to eq users_session.user
        expect(service_call.success?).to be_truthy
      end
    end
  end

  context 'for invalid token' do
    let(:token) { 'random uuid' }

    it 'does not assign user and fails', :aggregate_failures do
      expect(service_call.result).to be_nil
      expect(service_call.failure?).to be_truthy
    end
  end
end
