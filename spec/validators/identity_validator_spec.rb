# frozen_string_literal: true

describe IdentityValidator, type: :service do
  subject(:validator_call) { described_class.new.call(params: params) }

  context 'for invalid format' do
    let(:params) { { uid: 'uid', provider: 'provider', email: 'email', login: '' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Login must be filled')
    end
  end

  context 'for valid params' do
    let(:params) { { uid: 'uid', provider: 'provider', email: 'email', login: 'login' } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
