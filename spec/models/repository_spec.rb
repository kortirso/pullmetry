# frozen_string_literal: true

describe Repository do
  it 'factory should be valid' do
    repository = build :repository

    expect(repository).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:pull_requests).dependent(:destroy) }
  end
end
