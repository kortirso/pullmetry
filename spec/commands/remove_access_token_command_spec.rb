# frozen_string_literal: true

describe RemoveAccessTokenCommand do
  subject(:command) { instance.call({ access_token: access_token }) }

  let!(:instance) { described_class.new }

  # rubocop: disable RSpec/LetSetup
  context 'for invalid access_token' do
    let!(:access_token) { create :user }

    it 'does not destroy access token', :aggregate_failures do
      expect { command }.not_to change(AccessToken, :count)
      expect(command[:errors]).to eq ['Access token has invalid type']
      expect(command[:result]).to be_nil
    end
  end

  context 'for valid access_token' do
    let!(:access_token) { create :access_token }

    it 'does not destroy access token', :aggregate_failures do
      expect { command }.to change(AccessToken, :count).by(-1)
      expect(command[:errors]).to be_nil
      expect(command[:result]).to eq :ok
    end
  end
  # rubocop: enable RSpec/LetSetup
end
