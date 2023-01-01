# frozen_string_literal: true

describe Repository do
  it 'factory should be valid' do
    repository = build :repository

    expect(repository).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:pull_requests).dependent(:destroy) }
    it { is_expected.to have_one(:access_token).dependent(:destroy) }
    it { is_expected.to have_many(:insights).dependent(:destroy) }
    it { is_expected.to have_many(:entities).through(:pull_requests) }

    it {
      is_expected.to have_many(:pull_requests_comments).class_name('::PullRequests::Comment').through(:pull_requests)
    }

    it {
      is_expected.to have_many(:pull_requests_reviews).class_name('::PullRequests::Review').through(:pull_requests)
    }
  end
end
