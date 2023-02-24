# frozen_string_literal: true

describe Company do
  it 'factory should be valid' do
    company = build :company

    expect(company).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:repositories).dependent(:destroy) }
    it { is_expected.to have_one(:access_token).dependent(:destroy) }
    it { is_expected.to have_many(:insights).dependent(:destroy) }

    it {
      is_expected.to have_many(:pull_requests_comments).class_name('::PullRequests::Comment').through(:repositories)
    }

    it {
      is_expected.to have_many(:pull_requests_reviews).class_name('::PullRequests::Review').through(:repositories)
    }
  end
end
