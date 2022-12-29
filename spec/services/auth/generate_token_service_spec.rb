# frozen_string_literal: true

describe Auth::GenerateTokenService do
  subject(:service_call) { described_class.call(user: user) }

  let!(:user) { create :user }

  context 'without existing session' do
    it 'succeed' do
      expect(service_call.success?).to be_truthy
    end

    it 'creates users session' do
      expect { service_call.result }.to change(Users::Session, :count).by(1)
    end

    it 'returns token' do
      expect(service_call.result.is_a?(String)).to be_truthy
    end
  end

  context 'with existing session' do
    let!(:users_session) { create :users_session, user: user }

    it 'succeed' do
      expect(service_call.success?).to be_truthy
    end

    it 'creates users session', :aggregate_failures do
      service_call

      expect(Users::Session.find_by(id: users_session.id).nil?).to be_truthy
      expect(user.users_session.nil?).to be_falsy
    end

    it 'returns token' do
      expect(service_call.result.is_a?(String)).to be_truthy
    end
  end
end
