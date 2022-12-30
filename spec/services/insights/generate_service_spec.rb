# frozen_string_literal: true

describe Insights::GenerateService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:insightable) { create :repository }
  let!(:pr1) { create :pull_request, repository: insightable }
  let!(:pr2) { create :pull_request, repository: insightable }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }

  before do
    pr_entity1 = create :pull_requests_entity, pull_request: pr1, entity: entity1
    pr_entity2 = create :pull_requests_entity, pull_request: pr2, entity: entity2
    create :pull_requests_comment, pull_requests_entity: pr_entity1
    create :pull_requests_comment, pull_requests_entity: pr_entity2
  end

  context 'for unexisting insights' do
    it 'creates 2 insights' do
      expect { service_call }.to change(insightable.insights, :count).by(2)
    end
  end

  context 'for existing insight' do
    let!(:insight) { create :insight, insightable: insightable, entity: entity1, comments_count: 0 }

    it 'creates 1 insight' do
      expect { service_call }.to change(insightable.insights, :count).by(1)
    end

    it 'updates existing insight' do
      service_call

      expect(insight.reload.comments_count).to eq 1
    end
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
