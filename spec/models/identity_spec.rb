# frozen_string_literal: true

describe Identity do
  it 'factory should be valid' do
    identity = build :identity

    expect(identity).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
