# frozen_string_literal: true

describe Import::Fetchers::Github::Issues, type: :service do
  subject(:service_call) { described_class.new.call(repository: repository) }

  let(:repository) { create :repository }
  let(:valid_date) { (Date.current - 25.days).strftime('%Y-%m-%d') }
  let(:invalid_date) { (Date.current - 35.days).strftime('%Y-%m-%d') }
  let(:data) {
    [
      {
        'number' => 3,
        'created_at' => "#{valid_date}T20:09:31Z"
      },
      {
        'number' => 2,
        'created_at' => "#{valid_date}T20:09:31Z"
      },
      {
        'number' => 1,
        'created_at' => "#{invalid_date}T20:09:31Z"
      },
      {
        'number' => 4,
        'pull_request' => {},
        'created_at' => "#{invalid_date}T20:09:31Z"
      }
    ]
  }

  before do
    allow(Pullmetry::Container.resolve('api.github.client')).to(
      receive(:issues)
        .with(
          repository_link: 'https://github.com/company_name/repo_name',
          access_token: nil,
          params: { state: 'all', per_page: 100, page: 1 }
        )
        .and_return({ success: true, body: data })
    )
  end

  it 'returns 2 objects and succeeds' do
    expect(service_call[:result].size).to eq 2
  end
end
