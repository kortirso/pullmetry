# frozen_string_literal: true

describe Auth::AttachUserService, type: :service do
  subject(:service_call) { described_class.new.call(user: user, auth: oauth) }

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
    it 'creates new Identity' do
      expect { service_call }.to change(Identity, :count).by(1)
    end

    it 'new Identity has params from oauth and belongs to existed user', :aggregate_failures do
      service_call

      identity = Identity.last

      expect(identity.uid).to eq oauth[:uid]
      expect(identity.provider).to eq oauth[:provider]
      expect(identity.user).to eq user
    end
  end

  context 'for existed identity' do
    before { create :identity, uid: oauth[:uid] }

    it 'does not create new Identity and returns nil', :aggregate_failures do
      expect { service_call }.not_to change(Identity, :count)
      expect(service_call).to be_nil
    end
  end
end
