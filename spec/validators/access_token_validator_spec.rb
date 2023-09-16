# frozen_string_literal: true

describe AccessTokenValidator, type: :service do
  subject(:validator_call) { described_class.new.call(params: params) }

  context 'for invalid format' do
    let(:params) { { value: '' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Value must be filled')
    end
  end

  context 'for valid params' do
    let(:params) { { value: 'value' } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
