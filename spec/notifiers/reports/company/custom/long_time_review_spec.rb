# frozen_string_literal: true

describe Reports::Company::Custom::LongTimeReview, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without pull requests' do
    it 'generates payload' do
      expect(service_call).to eq "Company #{insightable.title} doesn't have long time review"
    end
  end

  context 'with pull requests' do
    let!(:repository) { create :repository, company: insightable }

    before { create :pull_request, repository: repository, created_at: 3.weeks.ago }

    it 'generates payload' do
      expect(
        service_call.dig(0, :title).include?("Repository long time review of #{repository.title}")
      ).to be_truthy
    end
  end
end
