# frozen_string_literal: true

describe Import::Fetchers::Gitlab::Comments, type: :service do
  subject(:service_call) { described_class.new.call(pull_request: pull_request, fetch_client: fetch_client) }

  let!(:repository) { create :repository, provider: Providerable::GITLAB }
  let!(:pull_request) { create :pull_request, repository: repository }
  let(:fetch_client) { double }
  let(:fetch_service) { double }
  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 1,
          'username' => 'octocat',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 2,
          'username' => 'octocat2',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 3,
          'username' => 'octocat3',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to(
      receive(:pull_request_comments)
        .with(external_id: nil, access_token: nil, pull_number: 1, params: { per_page: 25, page: 1 })
        .and_return({ success: true, body: data })
    )
    allow(fetch_service).to(
      receive(:pull_request_comments)
        .with(external_id: nil, access_token: nil, pull_number: 1, params: { per_page: 25, page: 2 })
        .and_return({ success: true, body: [] })
    )
  end

  it 'returns 3 objects' do
    expect(service_call[:result].size).to eq 3
  end
end
