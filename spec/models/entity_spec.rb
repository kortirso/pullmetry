# frozen_string_literal: true

describe Entity do
  it 'factory should be valid' do
    entity = build :entity

    expect(entity).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:identity).optional }
    it { is_expected.to have_many(:pull_requests).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:insights).dependent(:destroy) }
  end
end
