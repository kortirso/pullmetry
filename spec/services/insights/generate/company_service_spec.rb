# frozen_string_literal: true

describe Insights::Generate::CompanyService, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }
  let!(:pr1) { create :pull_request, repository: repository, entity: entity1 }
  let!(:pr2) { create :pull_request, repository: repository, entity: entity2 }
  let(:insightable) { repository.company }

  before do
    create :pull_requests_comment, pull_request: pr1, entity: entity2
    create :pull_requests_comment, pull_request: pr2, entity: entity1

    create :insight, insightable: repository, entity: entity1, comments_count: 1, changed_loc: 11, reviewed_loc: 3
    create :insight, insightable: repository, entity: entity2, comments_count: 2, changed_loc: 2

    create :subscription, user: insightable.user
    insightable.configuration.insight_fields = {
      comments_count: true,
      changed_loc: true,
      reviewed_loc: true,
      reviews_count: true,
      required_reviews_count: true,
      open_pull_requests_count: true,
      review_involving: true
    }
    insightable.save!
  end

  context 'for unexisting insights' do
    it 'creates 2 insights' do
      expect { service_call }.to change(insightable.insights.visible, :count).by(2)
    end

    context 'for private company' do
      before do
        insightable.configuration.private = true
        insightable.save!
      end

      it 'creates 2 insights' do
        expect { service_call }.to change(insightable.insights.hidden, :count).by(2)
      end
    end
  end

  context 'for existing insight' do
    let!(:insight) {
      create :insight, insightable: insightable, entity: entity1, comments_count: 0, changed_loc: 0, reviewed_loc: 0
    }

    it 'creates 1 insight and updates existing insight', :aggregate_failures do
      expect { service_call }.to change(insightable.insights.visible, :count).by(1)
      expect(insight.reload.comments_count).to eq 1
      expect(insight.changed_loc).to eq 11
      expect(insight.reviewed_loc).to eq 3
      expect(insight.reload.hidden).to be_falsy
    end

    context 'for private company' do
      before do
        insightable.configuration.private = true
        insightable.save!
      end

      it 'creates 2 insights', :aggregate_failures do
        expect { service_call }.to change(insightable.insights.hidden, :count).by(2)
        expect(insight.reload.hidden).to be_truthy
      end
    end
  end
end
