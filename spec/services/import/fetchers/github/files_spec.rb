# frozen_string_literal: true

describe Import::Fetchers::Github::Files, type: :service do
  subject(:service_call) { described_class.new.call(pull_request: pull_request, fetch_client: fetch_client) }

  let!(:repository) { create :repository, provider: Providerable::GITHUB }
  let!(:pull_request) { create :pull_request, repository: repository }
  let(:fetch_client) { double }
  let(:data) {
    [
      {
        'status' => 'added',
        'changes' => 1
      },
      {
        'status' => 'modified',
        'changes' => 2
      },
      {
        'status' => 'renamed',
        'changes' => 3
      }
    ]
  }

  before do
    allow(fetch_client).to(
      receive(:pull_request_files)
        .with({
          repository_link: 'https://github.com/company_name/repo_name',
          access_token: nil,
          pull_number: 1,
          params: { per_page: 100, page: 1 }
        })
        .and_return({ success: true, body: data })
    )
  end

  it 'returns 3 objects and succeeds', :aggregate_failures do
    expect(service_call.success?).to be_truthy
    expect(service_call.result.size).to eq 3
  end
end
