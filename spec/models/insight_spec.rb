# frozen_string_literal: true

describe Insight do
  it 'factory should be valid' do
    insight = build :insight

    expect(insight).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:insightable) }
    it { is_expected.to belong_to(:entity) }
  end
end
