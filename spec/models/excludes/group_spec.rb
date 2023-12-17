# frozen_string_literal: true

describe Excludes::Group do
  it 'factory should be valid' do
    excludes_group = build :excludes_group

    expect(excludes_group).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:insightable) }
    it { is_expected.to have_many(:excludes_rules).class_name('Excludes::Rule').dependent(:destroy) }
  end
end
