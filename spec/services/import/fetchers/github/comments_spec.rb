# frozen_string_literal: true

describe Import::Fetchers::Github::Comments, type: :service do
  subject(:service_call) { described_class.new.call(pull_request: pull_request, fetch_client: fetch_client) }

  let!(:repository) { create :repository, provider: Providerable::GITHUB }
  let!(:pull_request) { create :pull_request, repository: repository }
  let(:fetch_client) { double }
  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2013-10-02T08:57:14Z',
        'user' => {
          'id' => 1,
          'login' => 'octocat',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'user' => {
          'id' => 2,
          'login' => 'octocat2',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z',
        'user' => {
          'id' => 3,
          'login' => 'octocat3',
          'html_url' => 'https://github.com/octocat'
        }
      }
    ]
  }

  before do
    allow(fetch_client).to(
      receive(:pull_request_comments)
        .with(
          repository_link: 'https://github.com/company_name/repo_name',
          access_token: nil,
          pull_number: 1,
          params: { per_page: 100, page: 1 }
        )
        .and_return({ success: true, body: data })
    )
  end

  it 'returns 3 objects and succeeds', :aggregate_failures do
    expect(service_call.success?).to be_truthy
    expect(service_call.result.size).to eq 3
  end
end
