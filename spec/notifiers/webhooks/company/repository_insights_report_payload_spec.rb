# frozen_string_literal: true

describe Webhooks::Company::RepositoryInsightsReportPayload, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without insight' do
    it 'generates payload' do
      expect(service_call).to eq "Company #{insightable.title} doesn't have repository insights"
    end
  end

  context 'with insight' do
    let!(:repository) { create :repository, company: insightable }

    before { create :repositories_insight, repository: repository }

    it 'generates payload' do
      expect(
        service_call.dig(0, :title).include?("Repository insights of #{repository.title}")
      ).to be_truthy
    end
  end
end
