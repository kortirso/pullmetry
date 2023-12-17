# frozen_string_literal: true

describe Excludes::Rule do
  it 'factory should be valid' do
    excludes_rule = build :excludes_rule

    expect(excludes_rule).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:excludes_group) }
  end
end
