# frozen_string_literal: true

describe Import::Fetchers::Gitlab::Comments, type: :service do
  subject(:service_call) { described_class.new(pull_request: pull_request, fetch_client: fetch_client).call }

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
          'username' => 'octocat'
        }
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 2,
          'username' => 'octocat2'
        }
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 3,
          'username' => 'octocat3'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to(
      receive(:pull_request_comments).with(pull_number: 1, params: { per_page: 25, page: 1 }).and_return(data)
    )
    allow(fetch_service).to(
      receive(:pull_request_comments).with(pull_number: 1, params: { per_page: 25, page: 2 }).and_return([])
    )
  end

  it 'returns 3 objects' do
    result = service_call.result

    expect(result.size).to eq 3
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
