# frozen_string_literal: true

describe Reports::Company::Slack::Insights, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without insights' do
    it 'generates payload and succeeds' do
      expect(service_call[:blocks].size).to eq 2
    end

    context 'when insightable is unaccessable' do
      before do
        insightable.update!(accessable: false)
      end

      it 'renders message about unaccessability' do
        expect(service_call[:blocks].size).to eq 3
      end
    end
  end

  context 'with insights' do
    before do
      create :insight, insightable: insightable, reviews_count: 1
    end

    it 'generates payload and succeeds' do
      expect(service_call.dig(:blocks, 1, :elements).size).to eq 3
    end
  end
end
