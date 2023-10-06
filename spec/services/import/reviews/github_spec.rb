# frozen_string_literal: true

describe Import::Reviews::Github, type: :service do
  subject(:service_call) { described_class.new.call(pull_request: pull_request) }

  let!(:pull_request) { create :pull_request, entity: author_entity }
  let!(:author_entity) { create :entity, external_id: '10', provider: Providerable::GITHUB }
  let!(:entity) { create :entity }
  let(:data) {
    [
      {
        'id' => 3,
        'submitted_at' => '2011-04-11T20:09:31Z',
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        'id' => 2,
        'submitted_at' => '2011-04-10T20:09:31Z',
        'user' => {
          'login' => 'octocat',
          'id' => 1,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        'id' => 10,
        'submitted_at' => '2011-04-10T20:09:31Z',
        'user' => {
          'login' => 'octocat',
          'id' => 10,
          'avatar_url' => 'https://github.com/images/error/octocat_happy.gif'
        }
      }
    ]
  }

  before do
    allow(Pullmetry::Container.resolve('services.import.fetchers.github.reviews')).to(
      receive(:call).and_return({ result: data })
    )
  end

  context 'when there are no reviews' do
    it 'creates 2 new reviews' do
      expect { service_call }.to change(pull_request.pull_requests_reviews, :count).by(2)
    end
  end

  context 'when there is 1 existing review' do
    before { create :pull_requests_review, entity: entity, pull_request: pull_request, external_id: '2' }

    it 'creates 1 new review' do
      expect { service_call }.to change(pull_request.pull_requests_reviews, :count).by(1)
    end

    context 'when repository is unaccessable' do
      before { pull_request.repository.update!(accessable: false) }

      it 'does not create new review' do
        expect { service_call }.not_to change(pull_request.pull_requests_reviews, :count)
      end
    end
  end

  context 'when there is 1 old existing review' do
    before { create :pull_requests_review, entity: entity, pull_request: pull_request, external_id: '1' }

    it 'creates 2 new reviews and destroys old reviews', :aggregate_failures do
      service_call

      expect(pull_request.pull_requests_reviews.pluck(:external_id)).to match_array(%w[2 3])
      expect(pull_request.pull_requests_reviews.where(external_id: 1)).to be_empty
    end
  end
end
