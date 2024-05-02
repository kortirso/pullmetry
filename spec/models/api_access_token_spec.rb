# frozen_string_literal: true

describe ApiAccessToken do
  it 'factory should be valid' do
    api_access_token = build :api_access_token

    expect(api_access_token).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
