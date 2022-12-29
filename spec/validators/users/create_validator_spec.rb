# frozen_string_literal: true

describe Users::CreateValidator, type: :service do
  subject(:validator_call) { described_class.call(params: params) }

  context 'for invalid email format' do
    let(:params) { { email: '1gmail.com', password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Email has invalid format')
    end
  end

  context 'for invalid password length' do
    let(:params) { { email: '1@gmail.com', password: '1234qwe', password_confirmation: '1234qwe' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Password must be greater or equal 8 characters')
    end
  end

  context 'for not equal passwords' do
    let(:params) { { email: '1@gmail.com', password: '1234qweR', password_confirmation: '1234qwer' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Passwords must be equal')
    end
  end

  context 'for valid params' do
    let(:params) { { email: '1@gmail.com', password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'result does not contain errors' do
      expect(validator_call.size.zero?).to be_truthy
    end
  end
end
