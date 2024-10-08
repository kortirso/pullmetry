# frozen_string_literal: true

describe Authkeeper::Providers::Github do
  subject(:service_call) { described_class.new.call(params: { code: code }) }

  let(:code) { 'code' }
  let(:emails_response) { [] }
  let(:user_response) { { 'id' => 1, 'email' => 'email', 'login' => 'octocat' } }

  before do
    allow(Authkeeper::Container.resolve('api.github.auth_client')).to(
      receive(:fetch_access_token).and_return(token_response)
    )
    allow(Authkeeper::Container.resolve('api.github.client')).to(
      receive_messages(user: { body: user_response }, user_emails: { body: emails_response })
    )
  end

  context 'if code is invalid' do
    let(:token_response) { { 'message' => 'Bad credentials' } }

    it 'returns nil result', :aggregate_failures do
      expect(service_call[:result]).to be_nil
      expect(service_call[:errors]).not_to be_blank
    end

    context 'if code is valid' do
      let(:token_response) { { 'access_token' => 'access_token' } }

      context 'for user response with email' do
        it 'returns result and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({
            uid: '1',
            provider: 'github',
            login: 'octocat',
            email: 'email'
          })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'for user response without email' do
        let(:user_response) { { 'id' => 1, 'email' => nil, 'login' => 'octocat' } }

        context 'without emails in response' do
          it 'returns result and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({
              uid: '1',
              provider: 'github',
              login: 'octocat',
              email: nil
            })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'with email in response' do
          let(:emails_response) { [{ 'email' => 'private_email' }] }

          it 'returns result and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({
              uid: '1',
              provider: 'github',
              login: 'octocat',
              email: 'private_email'
            })
            expect(service_call[:errors]).to be_blank
          end
        end
      end
    end
  end
end
