# frozen_string_literal: true

describe Subscription do
  it 'factory should be valid' do
    subscription = build :subscription

    expect(subscription).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
