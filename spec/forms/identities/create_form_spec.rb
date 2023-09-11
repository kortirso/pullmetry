# frozen_string_literal: true

describe Identities::CreateForm, type: :service do
  subject(:form) { described_class.call(user: user, params: params) }

  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { uid: '' } }

    it 'does not create identity and fails', :aggregate_failures do
      expect { form }.not_to change(Identity, :count)
      expect(form.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { uid: '1234', login: 'name', provider: 'github', email: user.email } }

    context 'without entities' do
      it 'creates identity and succeeds', :aggregate_failures do
        expect { form }.to change(user.identities, :count).by(1)
        expect(form.success?).to be_truthy
      end

      it 'does not attach entities' do
        expect { form }.not_to change(user.entities, :count)
      end
    end

    context 'with entities' do
      before do
        create :entity, login: 'name', provider: 'github'
      end

      it 'creates identity and succeeds', :aggregate_failures do
        expect { form }.to change(user.identities, :count).by(1)
        expect(form.success?).to be_truthy
      end

      it 'attaches entities' do
        expect { form }.to change(user.entities, :count).by(1)
      end
    end
  end
end
