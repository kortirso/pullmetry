# frozen_string_literal: true

describe Vacation do
  it 'factory should be valid' do
    vacation = build :vacation

    expect(vacation).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
