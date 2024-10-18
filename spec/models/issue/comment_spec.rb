# frozen_string_literal: true

describe Issue::Comment do
  it 'factory should be valid' do
    issue_comment = build :issue_comment

    expect(issue_comment).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:issue) }
  end
end
