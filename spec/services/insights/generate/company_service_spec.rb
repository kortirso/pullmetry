# frozen_string_literal: true

describe Insights::Generate::CompanyService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:pr2) { create :pull_request, repository: repository, entity: entity1 }
  let!(:pr3) { create :pull_request, repository: repository, pull_merged_at: 10.seconds.after, entity: entity2 }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }

  before do
    create :pull_request, repository: repository, entity: entity1
    create :pull_requests_comment, entity: entity1, pull_request: pr3
    create :pull_requests_comment, entity: entity2, pull_request: pr2

    create :pull_requests_review,
           entity: entity2,
           pull_request: pr2,
           review_created_at: 10.seconds.after,
           required: true
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    context 'for unexisting insights' do
      it 'creates 2 insights' do
        expect { service_call }.to change(insightable.insights, :count).by(2)
      end
    end

    context 'for existing insight' do
      let!(:insight) { create :insight, insightable: insightable, entity: entity1, comments_count: 0 }

      it 'creates 1 insight and updates existing insight', :aggregate_failures do
        expect { service_call }.to change(insightable.insights, :count).by(1)
        expect(insight.reload.comments_count).to eq 1
      end
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end
end
