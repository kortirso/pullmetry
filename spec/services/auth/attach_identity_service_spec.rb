# frozen_string_literal: true

describe Auth::AttachIdentityService, type: :service do
  subject(:service_call) { instance.call(user: user, auth: oauth) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }
  let(:oauth) {
    {
      uid: '1234567890',
      provider: 'github',
      login: 'test_first_name',
      email: 'test@email.com'
    }
  }

  context 'for unexisting identity' do
    it 'new Identity has params from oauth and belongs to existed user', :aggregate_failures do
      expect { service_call }.to change(Identity, :count).by(1)

      identity = Identity.last

      expect(service_call[:result]).to eq identity
      expect(identity.uid).to eq oauth[:uid]
      expect(identity.provider).to eq oauth[:provider]
      expect(identity.user).to eq user
    end
  end

  context 'for existed identity' do
    let!(:identity) { create :identity, uid: oauth[:uid] }

    it 'does not create new Identity', :aggregate_failures do
      expect { service_call }.not_to change(Identity, :count)
      expect(service_call[:result]).to eq identity
    end
  end
end
