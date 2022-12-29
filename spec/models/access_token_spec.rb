# frozen_string_literal: true

describe AccessToken do
  it 'factory should be valid' do
    access_token = build :access_token

    expect(access_token).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:tokenable) }
  end
end
