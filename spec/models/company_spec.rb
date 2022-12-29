# frozen_string_literal: true

describe Company do
  it 'factory should be valid' do
    company = build :company

    expect(company).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
