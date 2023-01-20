# frozen_string_literal: true

describe Import::Fetchers::Gitlab::Reviews, type: :service do
  subject(:service_call) { described_class.new(pull_request: pull_request, fetch_client: fetch_client).call }

  let!(:repository) { create :repository, provider: Providerable::GITLAB }
  let!(:pull_request) { create :pull_request, repository: repository }
  let(:fetch_client) { double(GitlabApi::Client) }
  let(:fetch_service) { double }
  let(:data) {
    {
      'updated_at' => '2016-06-08T21:20:42.470Z',
      'approved_by' => [
        {
          'user' => {
            'id' => 1,
            'username' => 'octocat',
            'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
            'web_url' => 'https://gitlab.com/DouweM'
          }
        },
        {
          'user' => {
            'id' => 2,
            'username' => 'octocat2',
            'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
            'web_url' => 'https://gitlab.com/DouweM'
          }
        },
        {
          'user' => {
            'id' => 3,
            'username' => 'octocat3',
            'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
            'web_url' => 'https://gitlab.com/DouweM'
          }
        }
      ]
    }
  }

  before do
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to receive(:pull_request_reviews).and_return(data)
  end

  it 'returns 3 objects' do
    result = service_call.result

    expect(result['approved_by'].size).to eq 3
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
