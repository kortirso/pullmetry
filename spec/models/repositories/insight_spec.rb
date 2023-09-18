# frozen_string_literal: true

describe Repositories::Insight do
  it 'factory should be valid' do
    repositories_insight = build :repositories_insight

    expect(repositories_insight).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:repository).class_name('Repository') }
  end
end
