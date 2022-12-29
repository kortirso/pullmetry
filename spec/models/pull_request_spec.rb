# frozen_string_literal: true

describe PullRequest do
  it 'factory should be valid' do
    pull_request = build :pull_request

    expect(pull_request).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:repository) }
  end
end
