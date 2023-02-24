# frozen_string_literal: true

describe Math::FindAverageService, type: :service do
  subject(:service_call) { described_class.new.call(values: values, type: type, round: round) }

  let(:round) { 0 }

  context 'for ariphmetic mean' do
    let(:type) { nil }

    context 'for empty values' do
      let(:values) { [] }

      it 'returns result' do
        expect(service_call).to eq 0
      end
    end

    context 'for values' do
      let(:values) { [10, 35, 79] }

      it 'returns result' do
        expect(service_call).to eq 41
      end

      context 'with round' do
        let(:values) { [10, 35, 79] }
        let(:round) { 2 }

        it 'returns rounded result' do
          expect(service_call).to eq 41.33
        end
      end
    end
  end

  context 'for median' do
    let(:type) { :median }

    context 'for empty values' do
      let(:values) { [] }

      it 'returns result' do
        expect(service_call).to eq 0
      end
    end

    context 'for odd values' do
      let(:values) { [10, 35, 78] }

      it 'returns result' do
        expect(service_call).to eq 35
      end
    end

    context 'for even values' do
      let(:values) { [10, 35, 55, 78] }

      it 'returns result' do
        expect(service_call).to eq 45
      end
    end
  end

  context 'for geometric_mean mean' do
    let(:type) { :geometric_mean }

    context 'for empty values' do
      let(:values) { [] }

      it 'returns result' do
        expect(service_call).to eq 0
      end
    end

    context 'for values' do
      let(:values) { [2, 4, 8] }

      it 'returns result' do
        expect(service_call).to eq 4
      end

      context 'with round' do
        let(:values) { [2, 4, 9] }
        let(:round) { 2 }

        it 'returns rounded result' do
          expect(service_call).to eq 4.16
        end
      end
    end
  end
end
