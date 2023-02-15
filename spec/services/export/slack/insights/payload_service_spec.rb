# frozen_string_literal: true

describe Export::Slack::Insights::PayloadService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:insightable) { create :company }

  context 'without insights' do
    it 'generates payload' do
      service_call

      expect(service_call.result).to eq({
        blocks: []
      })
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'with insights' do
    before do
      create :insight, insightable: insightable
    end

    it 'generates payload' do
      service_call

      expect(service_call.result.dig(:blocks, 0, :elements).size).to eq 3
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end
end
