# frozen_string_literal: true

describe Issue do
  it 'factory should be valid' do
    issue = build :issue

    expect(issue).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:repository) }
    it { is_expected.to have_many(:comments).class_name('::Issue::Comment').dependent(:destroy) }
  end
end
