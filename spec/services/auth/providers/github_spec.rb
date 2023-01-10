# frozen_string_literal: true

describe Auth::Providers::Github do
  subject(:service_call) { described_class.new(auth_client: auth_client, api_client: api_client).call(code: code) }

  let(:auth_client) { double(GithubAuthApi::Client) }
  let(:api_client) { double(GithubApi::Client) }
  let(:code) { 'code' }
  let(:emails_response) { [] }
  let(:user_response) { { 'id' => 1, 'email' => 'email', 'login' => 'octocat' } }

  before do
    allow(auth_client).to receive(:fetch_access_token).and_return(token_response)
    allow(api_client).to receive(:user).and_return(user_response)
    allow(api_client).to receive(:user_emails).and_return(emails_response)
  end

  context 'if code is invalid' do
    let(:token_response) { { 'message' => 'Bad credentials' } }

    it 'returns nil result' do
      expect(service_call.result).to be_nil
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end

    context 'if code is valid' do
      let(:token_response) { { 'access_token' => 'access_token' } }

      context 'for user response with email' do
        it 'returns result' do
          expect(service_call.result).to eq({
            uid: 1,
            provider: 'github',
            login: 'octocat',
            email: 'email'
          })
        end

        it 'succeeds' do
          expect(service_call.success?).to be_truthy
        end
      end

      context 'for user response without email' do
        let(:user_response) { { 'id' => 1, 'email' => nil, 'login' => 'octocat' } }

        context 'without emails in response' do
          it 'returns result' do
            expect(service_call.result).to eq({
              uid: 1,
              provider: 'github',
              login: 'octocat',
              email: nil
            })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'with email in response' do
          let(:emails_response) { [{ 'email' => 'private_email' }] }

          it 'returns result' do
            expect(service_call.result).to eq({
              uid: 1,
              provider: 'github',
              login: 'octocat',
              email: 'private_email'
            })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end
      end
    end
  end
end
