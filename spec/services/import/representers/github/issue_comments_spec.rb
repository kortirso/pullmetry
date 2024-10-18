# frozen_string_literal: true

describe Import::Representers::Github::IssueComments, type: :service do
  subject(:service_call) { described_class.new.call(data: data) }

  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2013-10-02T08:57:14Z',
        'body' => '',
        'user' => {
          'id' => 1,
          'login' => 'octocat',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'body' => '',
        'user' => {
          'id' => 2,
          'login' => 'octocat2',
          'html_url' => 'https://github.com/octocat'
        }
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z',
        'body' => '**issue (non-blocking)**: Issue',
        'user' => {
          'id' => 3,
          'login' => 'octocat3',
          'html_url' => 'https://github.com/octocat'
        }
      }
    ]
  }

  it 'returns represented object' do
    expect(service_call).to eq(
      [
        {
          external_id: '3',
          comment_created_at: '2013-10-02T08:57:14Z'
        },
        {
          external_id: '2',
          comment_created_at: '2013-10-02T08:57:14Z'
        },
        {
          external_id: '1',
          comment_created_at: '2013-10-02T08:57:14Z'
        }
      ]
    )
  end
end
