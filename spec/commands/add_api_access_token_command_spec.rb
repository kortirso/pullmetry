# frozen_string_literal: true

describe AddApiAccessTokenCommand do
  subject(:command) { instance.call({ user: user }) }

  let!(:instance) { described_class.new }

  context 'for invalid user object' do
    let(:user) { create :company }

    it 'does not create api access token', :aggregate_failures do
      expect { command }.not_to change(ApiAccessToken, :count)
      expect(command[:errors]).to eq ['User has invalid type']
    end
  end

  context 'for valid user object' do
    let(:user) { create :user }

    it 'does not create api access token', :aggregate_failures do
      expect { command }.to change(ApiAccessToken, :count).by(1)
      expect(command[:errors]).to be_nil
      expect(command[:result]).to eq ApiAccessToken.last
    end
  end
end
