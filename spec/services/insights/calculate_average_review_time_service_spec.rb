# frozen_string_literal: true

describe Insights::CalculateAverageReviewTimeService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:pr1) { create :pull_request, repository: repository, pull_created_at: 24.hours.ago }
  let!(:pr2) { create :pull_request, repository: repository, pull_created_at: 48.hours.ago }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }

  before do
    pr_entity1 = create :pull_requests_entity, pull_request: pr1, entity: entity1
    pr_entity2 = create :pull_requests_entity, pull_request: pr2, entity: entity2
    create :pull_requests_review, pull_requests_entity: pr_entity1, review_created_at: 12.hours.ago
    create :pull_requests_review, pull_requests_entity: pr_entity1, review_created_at: 22.hours.ago
    create :pull_requests_review, pull_requests_entity: pr_entity2, review_created_at: 47.hours.ago
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    it 'generates average time' do
      expect(service_call.result.values).to eq([25_200, 3_600])
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    it 'generates average time' do
      expect(service_call.result.values).to eq([25_200, 3_600])
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end
end
