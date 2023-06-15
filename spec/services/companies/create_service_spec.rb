# frozen_string_literal: true

describe Companies::CreateService, type: :service do
  subject(:service_call) { described_class.call(user: user, params: params) }

  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { title: '' } }

    it 'does not create company and fails', :aggregate_failures do
      expect { service_call }.not_to change(Company, :count)
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { title: 'Title' } }

    it 'creates company and succeeds', :aggregate_failures do
      expect { service_call }.to change(user.companies, :count).by(1)
      expect(service_call.success?).to be_truthy
    end
  end
end
