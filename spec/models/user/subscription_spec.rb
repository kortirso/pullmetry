# frozen_string_literal: true

describe User::Subscription do
  it 'factory should be valid' do
    user_subscription = build :user_subscription

    expect(user_subscription).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
