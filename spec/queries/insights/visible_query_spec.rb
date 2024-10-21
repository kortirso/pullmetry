# frozen_string_literal: true

describe Insights::VisibleQuery, type: :service do
  subject(:query_resolve) { described_class.new(relation: relation).resolve(insightable: insightable) }

  let!(:insightable) { create :company }
  let!(:insight1) { create :insight, insightable: insightable, reviews_count: 1, comments_count: 2 }
  let!(:insight2) { create :insight, insightable: insightable, reviews_count: 2, comments_count: 1 }
  let(:relation) { insightable.insights }

  before { create :insight, insightable: insightable }

  context 'for regular account' do
    it 'returns list of insights' do
      expect(query_resolve.pluck(:id)).to contain_exactly(insight1.id, insight2.id)
    end
  end

  context 'for premium account' do
    before do
      create :user_subscription, user: insightable.user

      insightable.config.assign_attributes(
        main_attribute: :reviews_count
      )
      insightable.save!
    end

    it 'returns list of insights ordered by reviews_count' do
      expect(query_resolve.pluck(:id)).to contain_exactly(insight2.id, insight1.id)
    end
  end
end
