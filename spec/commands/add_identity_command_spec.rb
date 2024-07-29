# frozen_string_literal: true

describe AddIdentityCommand, type: :service do
  subject(:command) { instance.call(params.merge(user: user)) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { uid: '' } }

    it 'does not create identity and fails', :aggregate_failures do
      expect { command }.not_to change(Identity, :count)
      expect(command[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { uid: '1234', login: 'name', provider: 'github', email: user.email } }

    context 'without entities' do
      it 'creates identity and succeeds', :aggregate_failures do
        expect { command }.to change(user.identities, :count).by(1)
        expect(command[:result].is_a?(Identity)).to be_truthy
      end

      it 'does not attach entities', :aggregate_failures do
        expect { command }.not_to change(user.entities, :count)
        expect(command[:result].is_a?(Identity)).to be_truthy
      end
    end

    context 'with entities' do
      before do
        create :entity, login: 'name', provider: 'github'
      end

      it 'creates identity', :aggregate_failures do
        expect { command }.to(
          change(user.identities, :count).by(1)
            .and(change(user.entities, :count).by(1))
        )
        expect(command[:result].is_a?(Identity)).to be_truthy
      end
    end
  end
end
