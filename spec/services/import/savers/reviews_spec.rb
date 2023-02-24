# frozen_string_literal: true

# TODO: add tests for parallel request with creating similar entities
describe Import::Savers::Reviews, type: :service do
  subject(:service_call) { described_class.call(pull_request: pull_request, data: data) }

  let!(:pull_request) { create :pull_request, entity: author_entity }
  let!(:author_entity) { create :entity, external_id: '10', provider: Providerable::GITHUB }
  let(:data) {
    [
      {
        external_id: 3,
        review_created_at: '2011-04-11T20:09:31Z',
        author: {
          external_id: 1,
          provider: Providerable::GITHUB,
          login: 'octocat',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif',
          html_url: 'https://github.com/octocat'
        }
      },
      {
        external_id: 2,
        review_created_at: '2011-04-10T20:09:31Z',
        author: {
          external_id: 2,
          provider: Providerable::GITHUB,
          login: 'octocat',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif',
          html_url: 'https://github.com/octocat'
        }
      },
      {
        external_id: 10,
        review_created_at: '2011-04-10T20:09:31Z',
        author: {
          external_id: 10,
          provider: Providerable::GITHUB,
          login: 'octocat10',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif',
          html_url: 'https://github.com/octocat'
        }
      }
    ]
  }

  context 'when there are no reviews, no entities' do
    it 'creates 2 new pull requests entities' do
      expect { service_call }.to change(pull_request.pull_requests_entities, :count).by(2)
    end

    it 'creates 2 new entities' do
      expect { service_call }.to change(Entity, :count).by(2)
    end

    it 'creates 2 reviews' do
      expect { service_call }.to change(pull_request.pull_requests_reviews, :count).by(2)
    end

    context 'when there are entities' do
      let!(:entity1) { create :entity, external_id: '1', provider: Providerable::GITHUB }
      let!(:entity2) { create :entity, external_id: '2', provider: Providerable::GITHUB }

      it 'creates 2 new pull requests entities' do
        expect { service_call }.to change(pull_request.pull_requests_entities, :count).by(2)
      end

      it 'does not create new entities' do
        expect { service_call }.not_to change(Entity, :count)
      end

      it 'creates 2 reviews' do
        expect { service_call }.to change(pull_request.pull_requests_reviews, :count).by(2)
      end

      context 'when there are pr entities' do
        let!(:pr_entity1) { create :pull_requests_entity, pull_request: pull_request, entity: entity1 }
        let!(:pr_entity2) { create :pull_requests_entity, pull_request: pull_request, entity: entity2 }

        it 'does not create new pull requests entities' do
          expect { service_call }.not_to change(pull_request.pull_requests_entities, :count)
        end

        it 'does not create new entities' do
          expect { service_call }.not_to change(Entity, :count)
        end

        it 'creates 2 reviews' do
          expect { service_call }.to change(pull_request.pull_requests_reviews, :count).by(2)
        end

        context 'when there are old reviews' do
          before do
            create :pull_requests_review, pull_requests_entity: pr_entity1, external_id: '1'
            create :pull_requests_review, pull_requests_entity: pr_entity2, external_id: '4'
          end

          it 'creates 2 new reviews' do
            service_call

            expect(pull_request.pull_requests_reviews.pluck(:external_id)).to match_array(%w[2 3])
          end

          it 'destroys old reviews' do
            service_call

            expect(pull_request.pull_requests_reviews.where(external_id: %w[1 4])).to be_empty
          end
        end
      end
    end
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
