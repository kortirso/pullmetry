# frozen_string_literal: true

describe Companies::CreateValidator, type: :service do
  subject(:validator_call) { described_class.new.call(params: params) }

  context 'for invalid format' do
    let(:params) { { title: '' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Title must be filled')
    end
  end

  context 'for valid params' do
    let(:params) { { title: 'title' } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
