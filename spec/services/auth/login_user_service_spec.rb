# frozen_string_literal: true

describe Auth::LoginUserService, type: :service do
  subject(:service_call) { instance.call(auth: oauth) }

  let!(:instance) { described_class.new }
  let(:oauth) {
    {
      uid: '1234567890',
      provider: 'github',
      login: 'test_first_name',
      email: 'test@email.com'
    }
  }

  context 'for unexisted user and identity' do
    it 'new Identity has params from oauth and belongs to new User', :aggregate_failures do
      expect { service_call }.to(
        change(User, :count).by(1)
          .and(change(Identity, :count).by(1))
      )

      user = service_call[:result]

      identity = Identity.last

      expect(identity.uid).to eq oauth[:uid]
      expect(identity.provider).to eq oauth[:provider]
      expect(identity.user).to eq user
    end
  end

  context 'for existed user without identity' do
    let!(:user) { create :user, email: oauth[:email] }

    it 'does not create new User' do
      expect { service_call }.not_to change(User, :count)
    end

    it 'new Identity has params from oauth and belongs to existed user', :aggregate_failures do
      expect { service_call }.to change(Identity, :count).by(1)

      identity = Identity.last

      expect(service_call[:result]).to eq user
      expect(identity.uid).to eq oauth[:uid]
      expect(identity.provider).to eq oauth[:provider]
      expect(identity.user).to eq user
    end
  end

  context 'for existed user with identity' do
    let!(:user) { create :user, email: oauth[:email] }

    before { create :identity, uid: oauth[:uid], user: user }

    it 'does not create new User', :aggregate_failures do
      expect { service_call }.not_to change(User, :count)
      expect(service_call[:result]).to eq user
    end

    it 'does not create new Identity' do
      expect { service_call }.not_to change(Identity, :count)
    end
  end
end
