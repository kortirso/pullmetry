# frozen_string_literal: true

describe Converters::SecondsToTextService, type: :service do
  subject(:service_call) { described_class.new.call(value: value) }

  context 'when valus is nil' do
    let(:value) { nil }

    it 'returns -' do
      expect(service_call).to eq '-'
    end
  end

  context 'when value is less than 1 minute' do
    let(:value) { 59 }

    it 'returns -' do
      expect(service_call).to eq '1m'
    end
  end

  context 'when value is more than 1 hour' do
    let(:value) { 3_660 }

    it 'returns -' do
      expect(service_call).to eq '1h 1m'
    end
  end

  context 'when value is more than 1 day' do
    let(:value) { 86_460 }

    it 'returns -' do
      expect(service_call).to eq '1d 0h 1m'
    end
  end
end
