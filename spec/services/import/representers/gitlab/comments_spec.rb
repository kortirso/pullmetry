# frozen_string_literal: true

describe Import::Representers::Gitlab::Comments, type: :service do
  subject(:service_call) { described_class.new.call(data: data) }

  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2013-10-02T08:57:14Z',
        'body' => '',
        'author' => {
          'id' => 1,
          'username' => 'octocat',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'body' => '',
        'author' => {
          'id' => 2,
          'username' => 'octocat2',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z',
        'body' => '**issue (non-blocking)**: Issue',
        'author' => {
          'id' => 3,
          'username' => 'octocat3',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      }
    ]
  }

  # rubocop: disable RSpec/ExampleLength
  it 'returns represented object' do
    expect(service_call).to eq(
      [
        {
          external_id: '3',
          comment_created_at: '2013-10-02T08:57:14Z',
          parsed_body: nil,
          author: {
            external_id: '1',
            provider: Providerable::GITLAB,
            login: 'octocat',
            avatar_url: nil,
            html_url: 'https://gitlab.com/DouweM'
          }
        },
        {
          external_id: '2',
          comment_created_at: '2013-10-02T08:57:14Z',
          parsed_body: nil,
          author: {
            external_id: '2',
            provider: Providerable::GITLAB,
            login: 'octocat2',
            avatar_url: nil,
            html_url: 'https://gitlab.com/DouweM'
          }
        },
        {
          external_id: '1',
          comment_created_at: '2013-10-02T08:57:14Z',
          parsed_body: {
            title: 'issue',
            subject: 'Issue',
            decorations: ['non-blocking']
          },
          author: {
            external_id: '3',
            provider: Providerable::GITLAB,
            login: 'octocat3',
            avatar_url: nil,
            html_url: 'https://gitlab.com/DouweM'
          }
        }
      ]
    )
  end
  # rubocop: enable RSpec/ExampleLength
end
