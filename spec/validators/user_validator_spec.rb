# frozen_string_literal: true

describe UserValidator, type: :service do
  subject(:validator_call) { described_class.call(params: params) }

  context 'for invalid email format' do
    let(:params) { { email: '1gmail.com' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Email has invalid format')
    end
  end

  context 'for valid params' do
    let(:params) { { email: '1@gmail.com' } }

    it 'result does not contain errors' do
      expect(validator_call.size.zero?).to be_truthy
    end
  end
end
