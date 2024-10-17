# frozen_string_literal: true

describe PullRequest::Review do
  it 'factory should be valid' do
    pull_request_review = build :pull_request_review

    expect(pull_request_review).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pull_request).class_name('::PullRequest') }
    it { is_expected.to belong_to(:entity).class_name('::Entity') }
  end
end
