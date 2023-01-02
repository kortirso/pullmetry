# frozen_string_literal: true

describe Auth::LoginUserService, type: :service do
  subject(:service_call) { described_class.call(auth: oauth) }

  let!(:oauth) { create :oauth, :with_credentials }

  context 'for unexisted user and identity' do
    it 'creates new User' do
      expect { service_call }.to change(User, :count).by(1)
    end

    it 'returns new User' do
      expect(service_call.result).to eq User.last
    end

    it 'creates new Identity' do
      expect { service_call }.to change(Identity, :count).by(1)
    end

    it 'new Identity has params from oauth and belongs to new User' do
      user = service_call.result

      identity = Identity.last

      expect(identity.uid).to eq oauth.uid
      expect(identity.provider).to eq oauth.provider
      expect(identity.user).to eq user
    end
  end

  context 'for existed user without identity' do
    let!(:user) { create :user, email: oauth.info[:email] }

    it 'does not create new User' do
      expect { service_call }.not_to change(User, :count)
    end

    it 'returns existed user' do
      expect(service_call.result).to eq user
    end

    it 'creates new Identity' do
      expect { service_call }.to change(Identity, :count).by(1)
    end

    it 'new Identity has params from oauth and belongs to existed user' do
      service_call

      identity = Identity.last

      expect(identity.uid).to eq oauth.uid
      expect(identity.provider).to eq oauth.provider
      expect(identity.user).to eq user
    end
  end

  context 'for existed user with identity' do
    let!(:user) { create :user, email: oauth.info[:email] }
    let!(:identity) { create :identity, uid: oauth.uid, user: user }

    it 'does not create new User' do
      expect { service_call }.not_to change(User, :count)
    end

    it 'returns existed user' do
      expect(service_call.result).to eq user
    end

    it 'does not create new Identity' do
      expect { service_call }.not_to change(Identity, :count)
    end
  end
end
