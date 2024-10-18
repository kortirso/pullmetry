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
    it { is_expected.to have_many(:repository_insights).class_name('::Repositories::Insight').dependent(:destroy) }
    it { is_expected.to have_many(:comments).class_name('::PullRequest::Comment').through(:pull_requests) }
    it { is_expected.to have_many(:reviews).class_name('::PullRequest::Review').through(:pull_requests) }
    it { is_expected.to have_many(:issues).dependent(:destroy) }
  end

  describe '.access_token_status' do
    let!(:repository) { create :repository }

    context 'without access token' do
      it 'returns empty' do
        expect(repository.access_token_status).to eq 'empty'
      end
    end

    context 'with access token' do
      let!(:access_token) { create :access_token, tokenable: repository, value: 'random' }

      context 'when invalid format' do
        it 'returns invalid' do
          expect(repository.access_token_status).to eq 'invalid'
        end
      end

      context 'when valid format' do
        it 'returns valid' do
          access_token.update!(value: 'github_pat_****_******')

          expect(repository.access_token_status).to eq 'valid'
        end
      end
    end
  end
end
