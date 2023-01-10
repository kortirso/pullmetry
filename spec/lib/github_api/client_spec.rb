# frozen_string_literal: true

describe GithubApi::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { described_class.new(connection: connection, repository: repository) }

  let!(:repository) { create :repository }

  describe '.pull_requests' do
    subject(:client_request) { client.pull_requests }

    before do
      stubs.get('/repos/company_name/repo_name/pulls') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'number' => 1 }] }

      it 'returns user data' do
        expect(client_request).to eq body
      end
    end
  end

  describe '.pull_request_reviews' do
    subject(:client_request) { client.pull_request_reviews(pull_number: 1) }

    before do
      stubs.get('/repos/company_name/repo_name/pulls/1/reviews') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'id' => 1, 'submitted_at' => DateTime.now.to_s, 'user' => {} }] }

      it 'returns reviews data' do
        expect(client_request).to eq body
      end
    end
  end

  describe '.pull_request_comments' do
    subject(:client_request) { client.pull_request_comments(pull_number: 1) }

    before do
      stubs.get('/repos/company_name/repo_name/pulls/1/comments') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'id' => 1, 'created_at' => DateTime.now.to_s, 'user' => {} }] }

      it 'returns comment data' do
        expect(client_request).to eq body
      end
    end
  end

  describe '.user' do
    subject(:client_request) { client.user(access_token: access_token) }

    let(:access_token) { 'access_token' }

    before do
      stubs.get('/user') { [status, headers, body.to_json] }
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
      let(:body) { { 'id' => 1 } }

      it 'returns comment data' do
        expect(client_request).to eq body
      end
    end
  end

  describe '.user_emails' do
    subject(:client_request) { client.user_emails(access_token: access_token) }

    let(:access_token) { 'access_token' }

    before do
      stubs.get('/user/emails') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'email' => 'email' }] }

      it 'returns comment data' do
        expect(client_request).to eq body
      end
    end
  end
end
