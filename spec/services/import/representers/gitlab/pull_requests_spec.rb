# frozen_string_literal: true

describe Import::Representers::Gitlab::PullRequests, type: :service do
  subject(:service_call) { described_class.new.call(data: data) }

  let(:data) {
    [
      {
        'iid' => 3,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 1,
          'username' => 'octocat',
          'web_url' => 'https://gitlab.com/DouweM'
        },
        'reviewers' => [
          {
            'id' => 2,
            'username' => 'octocat2',
            'web_url' => 'https://gitlab.com/DouweM'
          }
        ]
      },
      {
        'iid' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 2,
          'username' => 'octocat2',
          'web_url' => 'https://gitlab.com/DouweM'
        }
      },
      {
        'iid' => 1,
        'draft' => true,
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
    expect(service_call.map(&:compact)).to eq(
      [
        {
          pull_number: 3,
          pull_created_at: '2013-10-02T08:57:14Z',
          author: {
            external_id: '1',
            provider: Providerable::GITLAB,
            login: 'octocat',
            avatar_url: nil,
            html_url: 'https://gitlab.com/DouweM'
          },
          reviewers: [
            {
              external_id: '2',
              provider: Providerable::GITLAB,
              login: 'octocat2',
              avatar_url: nil,
              html_url: 'https://gitlab.com/DouweM'
            }
          ]
        },
        {
          pull_number: 2,
          pull_created_at: '2013-10-02T08:57:14Z',
          author: {
            external_id: '2',
            provider: Providerable::GITLAB,
            login: 'octocat2',
            avatar_url: nil,
            html_url: 'https://gitlab.com/DouweM'
          },
          reviewers: []
        },
        {
          pull_number: 1,
          author: {
            external_id: '3',
            provider: Providerable::GITLAB,
            login: 'octocat3',
            avatar_url: nil,
            html_url: 'https://gitlab.com/DouweM'
          },
          reviewers: []
        }
      ]
    )
  end
  # rubocop: enable RSpec/ExampleLength
end
