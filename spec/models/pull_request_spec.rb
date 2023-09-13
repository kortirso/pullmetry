# frozen_string_literal: true

describe PullRequest do
  it 'factory should be valid' do
    pull_request = build :pull_request

    expect(pull_request).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:repository) }

    it {
      is_expected.to(
        have_many(:pull_requests_comments).class_name('::PullRequests::Comment').dependent(:destroy)
      )
    }

    it {
      is_expected.to(
        have_many(:pull_requests_reviews).class_name('::PullRequests::Review').dependent(:destroy)
      )
    }
  end
end
