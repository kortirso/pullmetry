# frozen_string_literal: true

describe PullRequests::Review do
  it 'factory should be valid' do
    pull_requests_review = build :pull_requests_review

    expect(pull_requests_review).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pull_requests_entity).class_name('::PullRequests::Entity') }
  end
end
