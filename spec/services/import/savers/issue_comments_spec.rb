# frozen_string_literal: true

describe Import::Savers::IssueComments, type: :service do
  subject(:service_call) { described_class.new.call(issue: issue, data: data) }

  let!(:issue) { create :issue }
  let(:data) {
    [
      {
        external_id: '3',
        comment_created_at: '2011-04-11T20:09:31Z'
      },
      {
        external_id: '2',
        comment_created_at: '2011-04-10T20:09:31Z'
      },
      {
        external_id: '10',
        comment_created_at: '2011-04-10T20:09:31Z'
      }
    ]
  }

  it 'creates 3 new comments' do
    expect { service_call }.to change(issue.comments, :count).by(3)
  end
end
