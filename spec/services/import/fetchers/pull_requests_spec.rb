# frozen_string_literal: true

describe Import::Fetchers::PullRequests, type: :service do
  subject(:service_call) { described_class.new(repository: repository, fetch_client: fetch_client).call }

  let(:repository) { create :repository, start_from_pull_number: start_from_pull_number }
  let(:fetch_client) { double }
  let(:fetch_service) { double }
  let(:data) {
    [
      {
        'number' => 3,
        'created_at' => '2011-04-11T20:09:31Z',
        'author' => {
          'external_id' => 1,
          'source' => Entity::GITHUB,
          'login' => 'octocat',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        'number' => 2,
        'created_at' => '2011-04-10T20:09:31Z',
        'author' => {
          'external_id' => 2,
          'source' => Entity::GITHUB,
          'login' => 'octocat2',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to(
      receive(:pull_requests).with(params: { state: 'all', per_page: 25, page: 1 }).and_return(data)
    )
    allow(fetch_service).to(
      receive(:pull_requests).with(params: { state: 'all', per_page: 25, page: 2 }).and_return([])
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

  context 'with start_from_pull_number at repository' do
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
