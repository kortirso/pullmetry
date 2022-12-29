# frozen_string_literal: true

describe Users::CreateService, type: :service do
  subject(:service_call) { described_class.call(params: params) }

  context 'for invalid params' do
    let(:params) { { email: '1gmail.com', password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'does not create User' do
      expect { service_call }.not_to change(User, :count)
    end

    it 'fails' do
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { email: '1@gmail.com', password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'creates User' do
      expect { service_call }.to change(User, :count).by(1)
    end

    it 'succeed' do
      expect(service_call.success?).to be_truthy
    end
  end
end
