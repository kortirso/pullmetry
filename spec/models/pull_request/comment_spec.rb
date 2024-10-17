# frozen_string_literal: true

describe PullRequest::Comment do
  it 'factory should be valid' do
    pull_request_comment = build :pull_request_comment

    expect(pull_request_comment).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pull_request).class_name('::PullRequest') }
    it { is_expected.to belong_to(:entity).class_name('::Entity') }
  end
end
