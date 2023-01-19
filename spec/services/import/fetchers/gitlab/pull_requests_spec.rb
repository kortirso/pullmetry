# frozen_string_literal: true

describe Import::Fetchers::Gitlab::PullRequests, type: :service do
  subject(:service_call) { described_class.new(repository: repository, fetch_client: fetch_client).call }

  let(:repository) { create :repository, provider: Providerable::GITLAB }
  let(:fetch_client) { double }
  let(:fetch_service) { double }
  let(:valid_date) { (Date.current - 25.days).strftime('%Y-%m-%d') }
  let(:invalid_date) { (Date.current - 35.days).strftime('%Y-%m-%d') }
  let(:data) {
    [
      {
        'iid' => 3,
        'created_at' => "#{valid_date}T20:09:31Z",
        'author' => {
          'id' => 1,
          'username' => 'octocat',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        'iid' => 2,
        'created_at' => "#{valid_date}T20:09:31Z",
        'author' => {
          'id' => 2,
          'username' => 'octocat2',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        'iid' => 1,
        'created_at' => "#{invalid_date}T20:09:31Z",
        'author' => {
          'id' => 3,
          'username' => 'octocat3',
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to receive(:pull_requests).with(params: { per_page: 25, page: 1 }).and_return(data)
    allow(fetch_service).to receive(:pull_requests).with(params: { per_page: 25, page: 2 }).and_return([])
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
end
