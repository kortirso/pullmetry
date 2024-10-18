# frozen_string_literal: true

# TODO: add tests for parallel request with creating similar entities
describe Import::Savers::Issues, type: :service do
  subject(:service_call) { described_class.new.call(repository: repository, data: data) }

  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }
  let(:data) {
    [
      {
        issue_number: 3,
        opened_at: nil,
        closed_at: nil
      },
      {
        issue_number: 2,
        opened_at: '2011-04-10T20:09:31Z',
        closed_at: '2011-04-10T20:09:31Z'
      },
      {
        issue_number: 12,
        opened_at: '2011-04-10T20:09:31Z',
        closed_at: '2011-04-10T20:09:31Z'
      }
    ]
  }

  context 'when there are no pull requests' do
    context 'when there are no exclude rules' do
      it 'creates 3 new issues' do
        expect { service_call }.to change(repository.issues, :count).by(3)
      end
    end

    context 'when data is empty' do
      let(:data) { [] }

      it 'does not create new issues' do
        expect { service_call }.not_to change(repository.issues, :count)
      end
    end
  end

  context 'when there is 1 existing issue' do
    let!(:issue) { create :issue, repository: repository, issue_number: 2 }

    it 'creates 2 new issues', :aggregate_failures do
      expect { service_call }.to change(repository.issues, :count).by(2)
      expect(issue.reload.open?).to be_falsy
    end
  end

  context 'when there is 1 old existing pull request' do
    let!(:issue) { create :issue, repository: repository, issue_number: 1 }

    it 'creates 3 new issues' do
      expect { service_call }.to change { repository.issues.pluck(:issue_number) }.from([1]).to([3, 2, 12])
    end

    it 'destroys old issue' do
      service_call

      expect(repository.issues.find_by(issue_number: issue.issue_number)).to be_nil
    end
  end
end
