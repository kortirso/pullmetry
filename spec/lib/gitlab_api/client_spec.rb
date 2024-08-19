# frozen_string_literal: true

describe GitlabApi::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { described_class.new(connection: connection, url: url) }

  let!(:repository) { create :repository, external_id: 2 }
  let!(:access_token) { create :access_token, tokenable: repository }
  let(:url) {
    link = URI(repository.link)
    "#{link.scheme}://#{link.host}"
  }

  describe '.pull_requests' do
    subject(:client_request) do
      client.pull_requests(external_id: repository.external_id, access_token: access_token.value)
    end

    before do
      stubs.get('/api/v4/projects/2/merge_requests') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'iid' => 1 }] }

      it 'returns user data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.pull_request_reviews' do
    subject(:client_request) do
      client.pull_request_reviews(external_id: repository.external_id, access_token: access_token.value, pull_number: 1)
    end

    before do
      stubs.get('/api/v4/projects/2/merge_requests/1/approvals') { [status, headers, body.to_json] }
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
      let(:body) { { 'approved_by' => [] } }

      it 'returns reviews data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.pull_request_comments' do
    subject(:client_request) do
      client.pull_request_comments(
        external_id: repository.external_id,
        access_token: access_token.value,
        pull_number: 1
      )
    end

    before do
      stubs.get('/api/v4/projects/2/merge_requests/1/notes') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'id' => 1, 'created_at' => DateTime.now.to_s, 'author' => {} }] }

      it 'returns comment data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end
end
