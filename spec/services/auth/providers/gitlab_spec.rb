# frozen_string_literal: true

describe Auth::Providers::Gitlab do
  subject(:service_call) { described_class.new.call(code: code) }

  let(:code) { 'code' }
  let(:user_response) { { 'id' => 1, 'email' => 'email', 'username' => 'labocat' } }

  before do
    allow(Pullmetry::Container.resolve('api.gitlab.auth_client')).to(
      receive(:fetch_access_token).and_return(token_response)
    )
    allow(Pullmetry::Container.resolve('api.gitlab.client')).to(
      receive(:user).and_return({ body: user_response })
    )
  end

  context 'if code is invalid' do
    let(:token_response) { { 'message' => 'Bad credentials' } }

    it 'returns nil result', :aggregate_failures do
      expect(service_call[:result]).to be_nil
      expect(service_call[:errors]).not_to be_empty
    end

    context 'if code is valid' do
      let(:token_response) { { 'access_token' => 'access_token' } }

      it 'returns result and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({
          uid: '1',
          provider: 'gitlab',
          login: 'labocat',
          email: 'email'
        })
        expect(service_call[:errors]).to be_nil
      end
    end
  end
end
