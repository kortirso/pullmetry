# frozen_string_literal: true

describe User::Vacation do
  it 'factory should be valid' do
    user_vacation = build :user_vacation

    expect(user_vacation).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
