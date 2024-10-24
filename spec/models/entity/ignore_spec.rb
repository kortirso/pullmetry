# frozen_string_literal: true

describe Entity::Ignore do
  it 'factory should be valid' do
    ignore = build :ignore

    expect(ignore).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:insightable) }
  end
end
