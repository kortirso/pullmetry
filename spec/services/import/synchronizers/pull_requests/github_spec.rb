# frozen_string_literal: true

describe Import::Synchronizers::PullRequests::Github, type: :service do
  subject(:service_call) { instance.call(repository: repository) }

  let!(:instance) { described_class.new }
  let!(:repository) { create :repository }
  let(:data) {
    [
      {
        'number' => 3,
        'created_at' => '2011-04-11T20:09:31Z',
        'closed_at' => nil,
        'merged_at' => nil,
        'draft' => true,
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        },
        'requested_reviewers' => [
          {
            'login' => 'octocat2',
            'id' => 2,
            'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
          }
        ]
      },
      {
        'number' => 2,
        'created_at' => '2011-04-10T20:09:31Z',
        'closed_at' => '2011-04-10T20:09:31Z',
        'merged_at' => '2011-04-10T20:09:31Z',
        'draft' => false,
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
    allow(Pullmetry::Container.resolve('services.import.fetchers.github.pull_requests')).to(
      receive(:call).and_return({ result: data })
    )
  end

  context 'when there are no pull requests' do
    it 'creates 2 new pull requests', :aggregate_failures do
      expect { service_call }.to change(repository.pull_requests, :count).by(2)
      expect(repository.pull_requests.find_by(pull_number: 3).pull_created_at).to be_nil
      expect(repository.pull_requests.find_by(pull_number: 2).pull_created_at).not_to be_nil
    end

    context 'when repository is unaccessable' do
      before { repository.update!(accessable: false) }

      it 'does not create new comments' do
        expect { service_call }.not_to change(repository.pull_requests, :count)
      end
    end
  end

  context 'when there is 1 existing pull request' do
    let!(:pull_request) { create :pull_request, repository: repository, pull_number: 2 }

    it 'creates 1 new pull request and updates existing pull request', :aggregate_failures do
      expect { service_call }.to change(repository.pull_requests, :count).by(1)
      expect(pull_request.reload.open?).to be_falsy
    end
  end

  context 'when there is 1 old existing pull request' do
    let!(:pull_request) { create :pull_request, repository: repository, pull_number: 1 }

    it 'creates 2 new pull requests and destroys old pull request', :aggregate_failures do
      service_call

      expect(repository.pull_requests.pluck(:pull_number)).to contain_exactly(2, 3)
      expect(repository.pull_requests.find_by(pull_number: pull_request.pull_number)).to be_nil
    end
  end
end
