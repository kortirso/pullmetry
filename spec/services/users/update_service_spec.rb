# frozen_string_literal: true

describe Users::UpdateService, type: :service do
  subject(:service_call) { described_class.call(user: user, params: params) }

  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { password: '1234qw', password_confirmation: '1234qwer' } }

    it 'does not update user' do
      expect { service_call }.not_to change(user, :password_digest)
    end

    it 'fails' do
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'updates user' do
      expect { service_call }.to change(user, :password_digest)
    end

    it 'succeed' do
      expect(service_call.success?).to be_truthy
    end
  end
end
