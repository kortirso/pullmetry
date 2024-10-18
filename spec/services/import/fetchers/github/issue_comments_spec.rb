# frozen_string_literal: true

describe Import::Fetchers::Github::IssueComments, type: :service do
  subject(:service_call) { described_class.new.call(issue: issue) }

  let!(:repository) { create :repository, provider: Providerable::GITHUB }
  let!(:issue) { create :issue, repository: repository }
  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2013-10-02T08:57:14Z'
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z'
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z'
      }
    ]
  }

  before do
    allow(Pullmetry::Container.resolve('api.github.client')).to(
      receive(:issue_comments)
        .with(
          repository_link: 'https://github.com/company_name/repo_name',
          access_token: nil,
          issue_number: 1,
          params: { per_page: 100, page: 1 }
        )
        .and_return({ success: true, body: data })
    )
  end

  it 'returns 3 objects' do
    expect(service_call[:result].size).to eq 3
  end
end
