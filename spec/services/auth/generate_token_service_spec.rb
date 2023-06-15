# frozen_string_literal: true

describe Auth::GenerateTokenService do
  subject(:service_call) { described_class.call(user: user) }

  let!(:user) { create :user }

  context 'without existing session' do
    it 'returns token and succeeds', :aggregate_failures do
      expect { service_call.result }.to change(Users::Session, :count).by(1)
      expect(service_call.result.is_a?(String)).to be_truthy
      expect(service_call.success?).to be_truthy
    end
  end

  context 'with existing session' do
    let!(:users_session) { create :users_session, user: user }

    it 'creates users session and succeeds', :aggregate_failures do
      service_call

      expect(Users::Session.find_by(id: users_session.id).nil?).to be_truthy
      expect(user.users_session.nil?).to be_falsy
      expect(service_call.result.is_a?(String)).to be_truthy
      expect(service_call.success?).to be_truthy
    end
  end
end
