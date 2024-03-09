# frozen_string_literal: true

describe SlackWebhooks::Company::RepositoryInsightsReportPayload, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without pull requests' do
    it 'generates payload' do
      expect(service_call.dig(:blocks, 0, :text, :text)).to eq(
        "*Company #{insightable.title} doesn't have repository insights*"
      )
    end
  end

  context 'with pull requests' do
    let!(:repository) { create :repository, company: insightable }

    before { create :repositories_insight, repository: repository }

    it 'generates payload' do
      expect(
        service_call.dig(:blocks, 0, :text, :text).include?("*Repository insights of #{repository.title}*")
      ).to be_truthy
    end
  end
end
