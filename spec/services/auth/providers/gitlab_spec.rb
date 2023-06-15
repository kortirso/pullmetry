# frozen_string_literal: true

describe Auth::Providers::Gitlab do
  subject(:service_call) { described_class.new(auth_client: auth_client, api_client: api_client).call(code: code) }

  let(:auth_client) { double(GitlabAuthApi::Client) }
  let(:api_client) { double(GitlabApi::Client) }
  let(:code) { 'code' }
  let(:user_response) { { 'id' => 1, 'email' => 'email', 'username' => 'labocat' } }

  before do
    allow(auth_client).to receive(:fetch_access_token).and_return(token_response)
    allow(api_client).to receive(:user).and_return({ body: user_response })
  end

  context 'if code is invalid' do
    let(:token_response) { { 'message' => 'Bad credentials' } }

    it 'returns nil result and succeeds', :aggregate_failures do
      expect(service_call.result).to be_nil
      expect(service_call.success?).to be_truthy
    end

    context 'if code is valid' do
      let(:token_response) { { 'access_token' => 'access_token' } }

      it 'returns result and succeeds', :aggregate_failures do
        expect(service_call.result).to eq({
          uid: '1',
          provider: 'gitlab',
          login: 'labocat',
          email: 'email'
        })
        expect(service_call.success?).to be_truthy
      end
    end
  end
end
