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
    subject(:client_request) {
      described_class.new(url: 'https://github.com', connection: connection)
    }

    before do
      stubs.get('/api/v1/stats') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request.get(path: '/api/v1/stats')).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) {
        {
          'data' => {}
        }
      }

      it 'returns players data' do
        expect(client_request.get(path: '/api/v1/stats')).to eq body
      end
    end
  end
end
