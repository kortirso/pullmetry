# frozen_string_literal: true

describe Entities::ForInsightableQuery, type: :service do
  subject(:query_resolve) { described_class.resolve(insightable: insightable) }

  let!(:insightable) { create :repository }
  let!(:pull_request) { create :pull_request, repository: insightable }
  let!(:pull_requests_comment) { create :pull_requests_comment, pull_request: pull_request }
  let!(:pull_requests_review1) { create :pull_requests_review, pull_request: pull_request }

  before { create :pull_requests_review }

  it 'returns list of insights' do
    expect(query_resolve.pluck(:id)).to(
      contain_exactly(pull_request.entity_id, pull_requests_comment.entity_id, pull_requests_review1.entity_id)
    )
  end
end
