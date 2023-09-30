# frozen_string_literal: true

describe AccessTokens::CreateForm, type: :service do
  subject(:form) { instance.call(tokenable: company, params: params) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }

  context 'for invalid params' do
    let(:params) { { value: '' } }

    it 'does not create access token and fails' do
      expect { form }.not_to change(AccessToken, :count)
    end
  end

  context 'for valid params' do
    let(:params) { { value: 'valid' } }

    it 'creates access token and succeeds' do
      form

      expect(AccessToken.where(tokenable: company).size).to eq 1
    end

    context 'when access token already exist' do
      let!(:access_token) { create :access_token, tokenable: company }

      it 'replaces old token with new one', :aggregate_failures do
        form

        expect(AccessToken.where(tokenable: company).size).to eq 1
        expect(AccessToken.find_by(id: access_token.id)).to be_nil
      end
    end
  end
end
