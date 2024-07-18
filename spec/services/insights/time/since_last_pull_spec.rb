# frozen_string_literal: true

describe Insights::Time::SinceLastPull, type: :service do
  subject(:service_call) { described_class.new.call(insightable: repository, pull_requests_ids: pull_requests_ids) }

  let!(:repository) { create :repository }
  let!(:entity) { create :entity }
  let!(:pull1) { create :pull_request, repository: repository, entity: entity, pull_created_at: 12.hours.before }
  let!(:pull2) { create :pull_request, repository: repository, entity: entity, pull_created_at: 8.hours.before }
  let(:pull_requests_ids) { [pull1.id, pull2.id] }

  it 'generates average time and succeeds', :aggregate_failures do
    expect(service_call[:result]).to eq({ entity.id => 28_800 })
    expect(service_call[:errors]).to be_blank
  end

  context 'when some PR does not have pull_created_at' do
    before { pull2.update!(pull_created_at: nil) }

    it 'generates average time without such PRs and succeeds', :aggregate_failures do
      expect(service_call[:result]).to eq({ entity.id => 43_200 })
      expect(service_call[:errors]).to be_blank
    end
  end
end
