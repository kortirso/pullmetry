# frozen_string_literal: true

describe HttpService::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }

  context 'for new connection' do
    it 'creates faraday connection' do
      client_service = described_class.new(url: 'https://github.com')

      expect(client_service.connection.is_a?(Faraday::Connection)).to be_truthy
    end
  end

  context 'for get request' do
    subject(:client_request) { described_class.new(url: 'https://api.github.com', connection: connection) }

    before do
      stubs.get('/user') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil', :aggregate_failures do
        result = client_request.get(path: '/user')

        expect(result[:success]).to be_falsy
        expect(result[:body]).to eq body
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) { { 'id' => 1 } }

      it 'returns user data', :aggregate_failures do
        result = client_request.get(path: '/user')

        expect(result[:success]).to be_truthy
        expect(result[:body]).to eq body
      end
    end
  end

  context 'for post request' do
    subject(:client_request) { described_class.new(url: 'https://github.com', connection: connection) }

    before do
      stubs.post('/login/oauth/access_token') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request.post(path: '/login/oauth/access_token')).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) { { 'access_token' => 'access_token' } }

      it 'returns access_token' do
        expect(client_request.post(path: '/login/oauth/access_token')).to eq body
      end
    end
  end
end
