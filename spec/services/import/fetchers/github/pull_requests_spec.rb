# frozen_string_literal: true

describe Import::Fetchers::Github::PullRequests, type: :service do
  subject(:service_call) { described_class.new(repository: repository, fetch_client: fetch_client).call }

  let(:repository) { create :repository }
  let(:fetch_client) { double }
  let(:fetch_service) { double }
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
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to(
      receive(:pull_requests).with(params: { state: 'all', per_page: 100, page: 1 }).and_return(data)
    )
  end

  context 'without start_from_pull_number at repository' do
    let(:start_from_pull_number) { nil }

    it 'returns 2 objects' do
      result = service_call.result

      expect(result.size).to eq 2
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'with start_from_pull_number at repository', skip: 'start_from_pull_number is not added' do
    let(:start_from_pull_number) { 3 }

    it 'returns 1 object' do
      result = service_call.result

      expect(result.size).to eq 1
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end
end
