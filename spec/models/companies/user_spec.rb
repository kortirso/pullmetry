# frozen_string_literal: true

describe Companies::User do
  it 'factory should be valid' do
    companies_user = build :companies_user

    expect(companies_user).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:invite) }
  end
end
