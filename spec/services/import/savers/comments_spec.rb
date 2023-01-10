# frozen_string_literal: true

# TODO: add tests for parallel request with creating similar entities
describe Import::Savers::Comments, type: :service do
  subject(:service_call) { described_class.call(pull_request: pull_request, data: data) }

  let!(:pull_request) { create :pull_request }
  let(:data) {
    [
      {
        external_id: 3,
        comment_created_at: '2011-04-11T20:09:31Z',
        author: {
          external_id: 1,
          provider: Providerable::GITHUB,
          login: 'octocat',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif'
        }
      },
      {
        external_id: 2,
        comment_created_at: '2011-04-10T20:09:31Z',
        author: {
          external_id: 2,
          provider: Providerable::GITHUB,
          login: 'octocat2',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif'
        }
      }
    ]
  }

  context 'when there are no comments, no entities' do
    it 'creates 2 new pull requests entities' do
      expect { service_call }.to change(pull_request.pull_requests_entities.reviewer, :count).by(2)
    end

    it 'creates 2 new entities' do
      expect { service_call }.to change(Entity, :count).by(2)
    end

    it 'creates 2 comments' do
      expect { service_call }.to change(pull_request.pull_requests_comments, :count).by(2)
    end

    context 'when there are identity' do
      let!(:identity) { create :identity, provider: Providerable::GITHUB, login: 'octocat' }

      it 'attaches entity to identity' do
        expect { service_call }.to change(identity.entities, :count).by(1)
      end
    end

    context 'when there are entities' do
      let!(:entity1) { create :entity, external_id: '1', provider: Providerable::GITHUB }
      let!(:entity2) { create :entity, external_id: '2', provider: Providerable::GITHUB }

      it 'creates 2 new pull requests entities' do
        expect { service_call }.to change(pull_request.pull_requests_entities.reviewer, :count).by(2)
      end

      it 'does not create new entities' do
        expect { service_call }.not_to change(Entity, :count)
      end

      it 'creates 2 comments' do
        expect { service_call }.to change(pull_request.pull_requests_comments, :count).by(2)
      end

      context 'when there are pr entities' do
        let!(:pr_entity1) { create :pull_requests_entity, pull_request: pull_request, entity: entity1 }
        let!(:pr_entity2) { create :pull_requests_entity, pull_request: pull_request, entity: entity2 }

        it 'does not create new pull requests entities' do
          expect { service_call }.not_to change(pull_request.pull_requests_entities.reviewer, :count)
        end

        it 'does not create new entities' do
          expect { service_call }.not_to change(Entity, :count)
        end

        it 'creates 2 comments' do
          expect { service_call }.to change(pull_request.pull_requests_comments, :count).by(2)
        end

        context 'when there are old comments' do
          before do
            create :pull_requests_comment, pull_requests_entity: pr_entity1, external_id: '1'
            create :pull_requests_comment, pull_requests_entity: pr_entity2, external_id: '4'
          end

          it 'creates 2 comments' do
            expect { service_call }.to change(pull_request.pull_requests_comments, :count).by(2)
          end
        end
      end
    end
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
