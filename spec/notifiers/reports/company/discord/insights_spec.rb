# frozen_string_literal: true

describe Reports::Company::Discord::Insights, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without insights' do
    it 'generates payload' do
      expect(service_call.size.positive?).to be_truthy
    end

    context 'when insightable is unaccessable' do
      before do
        insightable.update!(accessable: false)
      end

      it 'renders message about unaccessability' do
        expect(
          service_call.include?("**#{insightable.class.name} #{insightable.title} has access error**\n")
        ).to be_truthy
      end
    end
  end

  context 'with insights' do
    before do
      create :insight, insightable: insightable, reviews_count: 1
    end

    it 'generates payload' do
      expect(service_call.size.positive?).to be_truthy
    end
  end
end
