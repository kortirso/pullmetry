# frozen_string_literal: true

describe AccessTokens::CreateForm, type: :service do
  subject(:form) { described_class.call(tokenable: company, params: params) }

  let!(:company) { create :company }

  context 'for invalid params' do
    let(:params) { { value: '' } }

    it 'does not create access token and fails', :aggregate_failures do
      expect { form }.not_to change(AccessToken, :count)
      expect(form.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { value: 'valid' } }

    it 'creates access token and succeeds', :aggregate_failures do
      form

      expect(AccessToken.where(tokenable: company).size).to eq 1
      expect(form.success?).to be_truthy
    end

    context 'when access token already exist' do
      let!(:access_token) { create :access_token, tokenable: company }

      it 'replaces old token with new one', :aggregate_failures do
        form

        expect(AccessToken.where(tokenable: company).size).to eq 1
        expect(form.success?).to be_truthy
        expect(AccessToken.find_by(id: access_token.id)).to be_nil
      end
    end
  end
end
