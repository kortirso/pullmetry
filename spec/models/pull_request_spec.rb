# frozen_string_literal: true

describe PullRequest do
  it 'factory should be valid' do
    pull_request = build :pull_request

    expect(pull_request).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:repository) }
    it { is_expected.to have_many(:comments).class_name('::PullRequest::Comment').dependent(:destroy) }
    it { is_expected.to have_many(:reviews).class_name('::PullRequest::Review').dependent(:destroy) }
  end
end
