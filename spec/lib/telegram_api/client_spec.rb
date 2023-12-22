# frozen_string_literal: true

describe TelegramApi::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { described_class.new(connection: connection) }

  let(:bot_secret) { 'secret' }
  let(:chat_id) { 'chat_id' }
  let(:text) { 'text' }

  describe '.send_message' do
    subject(:client_request) do
      client.send_message(bot_secret: bot_secret, chat_id: chat_id, text: text)
    end

    before do
      stubs.get('/botsecret/sendMessage?chat_id=chat_id&text=text') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'ok' => true }] }

      it 'returns user data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end
end
