# frozen_string_literal: true

describe Import::Synchronizers::Issues::Github, type: :service do
  subject(:service_call) { instance.call(repository: repository) }

  let!(:instance) { described_class.new }
  let!(:repository) { create :repository }
  let(:data) {
    [
      {
        'number' => 3,
        'created_at' => '2011-04-11T20:09:31Z',
        'closed_at' => nil
      },
      {
        'number' => 2,
        'created_at' => '2011-04-10T20:09:31Z',
        'closed_at' => '2011-04-10T20:09:31Z'
      }
    ]
  }

  before do
    allow(Pullmetry::Container.resolve('services.import.fetchers.github.issues')).to(
      receive(:call).and_return({ result: data })
    )
  end

  context 'when there are no issues' do
    it 'creates 2 new issues' do
      expect { service_call }.to change(repository.issues, :count).by(2)
    end

    context 'when repository is unaccessable' do
      before { repository.update!(accessable: false) }

      it 'does not create new issues' do
        expect { service_call }.not_to change(repository.issues, :count)
      end
    end
  end

  context 'when there is 1 existing issue' do
    let!(:issue) { create :issue, repository: repository, issue_number: 2 }

    it 'creates 1 new issue and updates existing issue', :aggregate_failures do
      expect { service_call }.to change(repository.issues, :count).by(1)
      expect(issue.reload.open?).to be_falsy
    end
  end

  context 'when there is 1 old existing pull request' do
    let!(:issue) { create :issue, repository: repository, issue_number: 1 }

    it 'creates 2 new pull requests and destroys old pull request', :aggregate_failures do
      service_call

      expect(repository.issues.pluck(:issue_number)).to contain_exactly(2, 3)
      expect(repository.issues.find_by(issue_number: issue.issue_number)).to be_nil
    end
  end
end
