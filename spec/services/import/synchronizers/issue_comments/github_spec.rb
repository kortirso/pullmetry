# frozen_string_literal: true

describe Import::Synchronizers::IssueComments::Github, type: :service do
  subject(:service_call) { instance.call(issue: issue) }

  let!(:instance) { described_class.new }
  let!(:issue) { create :issue }
  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2011-04-11T20:09:31Z'
      },
      {
        'id' => 2,
        'created_at' => '2011-04-10T20:09:31Z'
      },
      {
        'id' => 10,
        'created_at' => '2011-04-10T20:09:31Z'
      }
    ]
  }

  before do
    allow(Pullmetry::Container.resolve('services.import.fetchers.github.issue_comments')).to(
      receive(:call).and_return({ result: data })
    )
  end

  context 'when there are no comments' do
    it 'creates 3 new comments' do
      expect { service_call }.to change(issue.comments, :count).by(3)
    end

    context 'when repository is unaccessable' do
      before { issue.repository.update!(accessable: false) }

      it 'does not create new comments' do
        expect { service_call }.not_to change(issue.comments, :count)
      end
    end
  end

  context 'when there is 1 existing comment' do
    before { create :issue_comment, issue: issue, external_id: '2' }

    it 'creates 2 new comments' do
      expect { service_call }.to change(issue.comments, :count).by(2)
    end
  end

  context 'when there is 1 old existing comment' do
    before { create :issue_comment, issue: issue, external_id: '1' }

    it 'creates 2 new comments and destroys old comments', :aggregate_failures do
      service_call

      expect(issue.comments.pluck(:external_id)).to match_array(%w[2 3 10])
      expect(issue.comments.where(external_id: 1)).to be_empty
    end
  end
end
