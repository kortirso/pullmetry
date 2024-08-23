# frozen_string_literal: true

describe Authkeeper::GitlabApi::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { described_class.new(connection: connection, url: url) }

  let!(:repository) { create :repository, external_id: 2 }
  let!(:access_token) { create :access_token, tokenable: repository }
  let(:url) {
    link = URI(repository.link)
    "#{link.scheme}://#{link.host}"
  }

  describe '.user' do
    subject(:client_request) { client.user(access_token: access_token) }

    let(:access_token) { 'access_token' }

    before do
      stubs.get('api/v4/user') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil', :aggregate_failures do
        expect(client_request[:success]).to be_falsy
        expect(client_request[:body]).to eq body
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) { { 'id' => 1 } }

      it 'returns comment data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end
end
