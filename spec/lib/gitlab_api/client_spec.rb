# frozen_string_literal: true

describe GitlabApi::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { described_class.new(connection: connection, repository: repository, url: url) }

  let!(:repository) { create :repository, external_id: 2 }
  let(:url) {
    link = URI(repository.link)
    "#{link.scheme}://#{link.host}"
  }

  describe '.pull_requests' do
    subject(:client_request) { client.pull_requests }

    before do
      stubs.get('/api/v4/projects/2/merge_requests') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) { [{ 'iid' => 1 }] }

      it 'returns user data' do
        expect(client_request).to eq body
      end
    end
  end

  describe '.pull_request_reviews' do
    subject(:client_request) { client.pull_request_reviews(pull_number: 1) }

    before do
      stubs.get('/api/v4/projects/2/merge_requests/1/approvals') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) { { 'approved_by' => [] } }

      it 'returns reviews data' do
        expect(client_request).to eq body
      end
    end
  end

  describe '.pull_request_comments' do
    subject(:client_request) { client.pull_request_comments(pull_number: 1) }

    before do
      stubs.get('/api/v4/projects/2/merge_requests/1/notes') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) { [{ 'id' => 1, 'created_at' => DateTime.now.to_s, 'author' => {} }] }

      it 'returns comment data' do
        expect(client_request).to eq body
      end
    end
  end
end
