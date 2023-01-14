# frozen_string_literal: true

describe Import::SyncCommentsService, type: :service do
  subject(:service_call) { described_class.new(fetch_service: fetch_service).call(pull_request: pull_request) }

  let!(:pull_request) { create :pull_request }
  let!(:pull_requests_entity) { create :pull_requests_entity, pull_request: pull_request, origin: 'reviewer' }
  let(:fetch_service) { double(Import::Fetchers::Reviews) }
  let(:fetcher) { double }
  let(:fetch_data) { double }
  let(:data) {
    [
      {
        'id' => 3,
        'created_at' => '2011-04-11T20:09:31Z',
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        'id' => 2,
        'created_at' => '2011-04-10T20:09:31Z',
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      }
    ]
  }

  before do
    allow(fetch_service).to receive(:new).and_return(fetcher)
    allow(fetcher).to receive(:call).and_return(fetch_data)
    allow(fetch_data).to receive(:result).and_return(data)
  end

  context 'when there are no comments' do
    it 'creates 2 new comments' do
      expect { service_call }.to change(pull_request.pull_requests_comments, :count).by(2)
    end
  end

  context 'when there is 1 existing comment' do
    before { create :pull_requests_comment, pull_requests_entity: pull_requests_entity, external_id: '2' }

    it 'creates 1 new comment' do
      expect { service_call }.to change(pull_request.pull_requests_comments, :count).by(1)
    end
  end

  context 'when there is 1 old existing comment' do
    before { create :pull_requests_comment, pull_requests_entity: pull_requests_entity, external_id: '1' }

    it 'creates 2 new comments' do
      service_call

      expect(pull_request.pull_requests_comments.pluck(:external_id)).to match_array(%w[2 3])
    end

    it 'destroys old comments' do
      service_call

      expect(pull_request.pull_requests_comments.where(external_id: 1)).to be_empty
    end
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
