# frozen_string_literal: true

describe Entities::ForInsightableQuery, type: :service do
  subject(:query_resolve) { described_class.resolve(insightable: insightable) }

  let!(:insightable) { create :repository }
  let!(:pull_request) { create :pull_request, repository: insightable }

  it 'returns list of insights' do
    expect(query_resolve.pluck(:id)).to contain_exactly(pull_request.entity_id)
  end
end
