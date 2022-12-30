# frozen_string_literal: true

describe Import::SyncRepositoryService, type: :service do
  subject(:service_call) { described_class.new(fetch_service: fetch_service).call(repository: repository) }

  let!(:repository) { create :repository }
  let(:fetch_service) { double }
  let(:fetcher) { double }
  let(:fetch_data) { double }
  let(:data) {
    [
      {
        'number' => 3,
        'created_at' => '2011-04-11T20:09:31Z',
        'closed_at' => nil,
        'merged_at' => nil,
        'state' => 'open',
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        },
        'requested_reviewers' => []
      },
      {
        'number' => 2,
        'created_at' => '2011-04-10T20:09:31Z',
        'closed_at' => '2011-04-10T20:09:31Z',
        'merged_at' => '2011-04-10T20:09:31Z',
        'state' => 'closed',
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        },
        'requested_reviewers' => []
      }
    ]
  }

  before do
    allow(fetch_service).to receive(:new).and_return(fetcher)
    allow(fetcher).to receive(:call).and_return(fetch_data)
    allow(fetch_data).to receive(:result).and_return(data)
  end

  context 'when there are no pull requests' do
    it 'creates 2 new pull requests' do
      expect { service_call }.to change(repository.pull_requests, :count).by(2)
    end
  end

  context 'when there is 1 existing pull request' do
    let!(:pull_request) { create :pull_request, repository: repository, pull_number: 2 }

    it 'creates 1 new pull request' do
      expect { service_call }.to change(repository.pull_requests, :count).by(1)
    end

    it 'updates existing pull request' do
      service_call

      expect(pull_request.reload.open).to be_falsy
    end
  end

  context 'when there is 1 old existing pull request' do
    let!(:pull_request) { create :pull_request, repository: repository, pull_number: 1 }

    it 'creates 2 new pull requests' do
      expect { service_call }.to change { repository.pull_requests.pluck(:pull_number) }.from([1]).to([3, 2])
    end

    it 'destroys old pull request' do
      service_call

      expect(repository.pull_requests.find_by(pull_number: pull_request.pull_number)).to be_nil
    end
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
