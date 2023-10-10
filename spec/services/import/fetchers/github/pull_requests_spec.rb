# frozen_string_literal: true

describe Import::Fetchers::Github::PullRequests, type: :service do
  subject(:service_call) { described_class.new.call(repository: repository, fetch_client: fetch_client) }

  let(:repository) { create :repository, accessable: false }
  let(:fetch_client) { double }
  let(:valid_date) { (Date.current - 25.days).strftime('%Y-%m-%d') }
  let(:invalid_date) { (Date.current - 35.days).strftime('%Y-%m-%d') }
  let(:data) {
    [
      {
        'number' => 3,
        'created_at' => "#{valid_date}T20:09:31Z",
        'author' => {
          'external_id' => 1,
          'provider' => Providerable::GITHUB,
          'login' => 'octocat',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'number' => 2,
        'created_at' => "#{valid_date}T20:09:31Z",
        'author' => {
          'external_id' => 2,
          'provider' => Providerable::GITHUB,
          'login' => 'octocat2',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'number' => 1,
        'created_at' => "#{invalid_date}T20:09:31Z",
        'author' => {
          'external_id' => 3,
          'provider' => Providerable::GITHUB,
          'login' => 'octocat3',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
          'html_url' => 'https://github.com/octocat'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to(
      receive(:pull_requests)
        .with(
          repository_link: 'https://github.com/company_name/repo_name',
          access_token: nil,
          params: { state: 'all', per_page: 100, page: 1 }
        )
        .and_return({ success: true, body: data })
    )
  end

  context 'without start_from_pull_number at repository' do
    let(:start_from_pull_number) { nil }

    it 'returns 2 objects and succeeds', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(service_call.result.size).to eq 2
      expect(repository.reload.accessable).to be_truthy
    end
  end

  context 'with start_from_pull_number at repository', skip: 'start_from_pull_number is not added' do
    let(:start_from_pull_number) { 3 }

    it 'returns 1 object and succeeds', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(service_call.result.size).to eq 1
    end
  end
end
