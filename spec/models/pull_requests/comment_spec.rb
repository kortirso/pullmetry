# frozen_string_literal: true

describe PullRequests::Comment do
  it 'factory should be valid' do
    pull_requests_comment = build :pull_requests_comment

    expect(pull_requests_comment).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pull_request).class_name('::PullRequest') }
    it { is_expected.to belong_to(:entity).class_name('::Entity') }
  end
end
