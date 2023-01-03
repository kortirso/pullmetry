# frozen_string_literal: true

describe Identities::CreateService, type: :service do
  subject(:service_call) { described_class.call(user: user, params: params) }

  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { uid: '' } }

    it 'does not create identity' do
      expect { service_call }.not_to change(Identity, :count)
    end

    it 'fails' do
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { uid: '1234', login: 'name', provider: 'github', email: user.email } }

    context 'without entities' do
      it 'creates identity' do
        expect { service_call }.to change(user.identities, :count).by(1)
      end

      it 'does not attach entities' do
        expect { service_call }.not_to change(user.entities, :count)
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end

    context 'with entities' do
      before do
        create :entity, login: 'name', source: 'github'
      end

      it 'creates identity' do
        expect { service_call }.to change(user.identities, :count).by(1)
      end

      it 'attaches entities' do
        expect { service_call }.to change(user.entities, :count).by(1)
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end
  end
end
