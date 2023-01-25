# frozen_string_literal: true

describe Import::Fetchers::Github::Reviews, type: :service do
  subject(:service_call) { described_class.new(pull_request: pull_request, fetch_client: fetch_client).call }

  let!(:repository) { create :repository, provider: Providerable::GITHUB }
  let!(:pull_request) { create :pull_request, repository: repository }
  let(:fetch_client) { double }
  let(:fetch_service) { double }
  let(:data) {
    [
      {
        'id' => 3,
        'submitted_at' => '2013-10-02T08:57:14Z',
        'state' => 'APPROVED',
        'user' => {
          'id' => 1,
          'login' => 'octocat',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'id' => 2,
        'submitted_at' => '2013-10-02T08:57:14Z',
        'state' => 'APPROVED',
        'user' => {
          'id' => 2,
          'login' => 'octocat2',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'id' => 1,
        'submitted_at' => '2013-10-02T08:57:14Z',
        'state' => 'COMMENTED',
        'user' => {
          'id' => 3,
          'login' => 'octocat3',
          'html_url' => 'https://github.com/octocat'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to receive(:new).and_return(fetch_service)
    allow(fetch_service).to(
      receive(:pull_request_reviews).with(pull_number: 1, params: { per_page: 50, page: 1 }).and_return(data)
    )
  end

  it 'returns 2 objects' do
    result = service_call.result

    expect(result.size).to eq 2
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
