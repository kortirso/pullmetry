# frozen_string_literal: true

describe Authkeeper::GenerateTokenService do
  subject(:service_call) { instance.call(user_session: user_session) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }
  let!(:user_session) { create :user_session, user: user }

  context 'without existing session' do
    it 'returns token and succeeds', :aggregate_failures do
      service_call

      expect(service_call[:result].is_a?(String)).to be_truthy
      expect(service_call[:errors]).to be_blank
    end
  end

  context 'with existing session' do
    before { create :user_session, user: user }

    it 'returns token and succeeds', :aggregate_failures do
      service_call

      expect(service_call[:result].is_a?(String)).to be_truthy
      expect(service_call[:errors]).to be_blank
    end
  end
end
