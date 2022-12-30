# frozen_string_literal: true

describe PullRequests::Entity do
  it 'factory should be valid' do
    pull_requests_entity = build :pull_requests_entity

    expect(pull_requests_entity).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pull_request).class_name('::PullRequest') }
    it { is_expected.to belong_to(:entity).class_name('::Entity') }
    it { is_expected.to have_many(:pull_requests_comments).class_name('::PullRequests::Comment').dependent(:destroy) }
  end
end
