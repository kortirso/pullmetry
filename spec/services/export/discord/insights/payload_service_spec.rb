# frozen_string_literal: true

describe Export::Discord::Insights::PayloadService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without insights' do
    it 'generates payload' do
      service_call

      expect(service_call.result.size.positive?).to be_truthy
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'with insights' do
    before do
      create :insight, insightable: insightable, reviews_count: 1
    end

    it 'generates payload' do
      service_call

      expect(service_call.result.size.positive?).to be_truthy
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end
end
