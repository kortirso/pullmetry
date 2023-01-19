# frozen_string_literal: true

describe Import::Representers::Gitlab::Comments, type: :service do
  subject(:service_call) { described_class.new.call(data: data) }

  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 1,
          'username' => 'octocat'
        }
      },
      {
        'id' => 2,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 2,
          'username' => 'octocat2'
        }
      },
      {
        'id' => 1,
        'created_at' => '2013-10-02T08:57:14Z',
        'author' => {
          'id' => 3,
          'username' => 'octocat3'
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
          author: {
            external_id: '1',
            provider: Providerable::GITLAB,
            login: 'octocat',
            avatar_url: nil
          }
        },
        {
          external_id: '2',
          comment_created_at: '2013-10-02T08:57:14Z',
          author: {
            external_id: '2',
            provider: Providerable::GITLAB,
            login: 'octocat2',
            avatar_url: nil
          }
        },
        {
          external_id: '1',
          comment_created_at: '2013-10-02T08:57:14Z',
          author: {
            external_id: '3',
            provider: Providerable::GITLAB,
            login: 'octocat3',
            avatar_url: nil
          }
        }
      ]
    )
  end
  # rubocop: enable RSpec/ExampleLength
end
