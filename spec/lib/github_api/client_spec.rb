# frozen_string_literal: true

describe GithubApi::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { described_class.new(connection: connection) }

  let!(:repository) { create :repository }
  let!(:access_token) { create :access_token, tokenable: repository }

  describe '.pull_requests' do
    subject(:client_request) do
      client.pull_requests(repository_link: repository.link, access_token: access_token.value)
    end

    before do
      stubs.get('/repos/company_name/repo_name/pulls') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'number' => 1 }] }

      it 'returns user data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.pull_request_reviews' do
    subject(:client_request) do
      client.pull_request_reviews(repository_link: repository.link, access_token: access_token.value, pull_number: 1)
    end

    before do
      stubs.get('/repos/company_name/repo_name/pulls/1/reviews') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'id' => 1, 'submitted_at' => DateTime.now.to_s, 'user' => {} }] }

      it 'returns reviews data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.pull_request_comments' do
    subject(:client_request) do
      client.pull_request_comments(repository_link: repository.link, access_token: access_token.value, pull_number: 1)
    end

    before do
      stubs.get('/repos/company_name/repo_name/pulls/1/comments') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'id' => 1, 'created_at' => DateTime.now.to_s, 'user' => {} }] }

      it 'returns comment data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.pull_request_files' do
    subject(:client_request) do
      client.pull_request_files(repository_link: repository.link, access_token: access_token.value, pull_number: 1)
    end

    before do
      stubs.get('/repos/company_name/repo_name/pulls/1/files') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'changes' => 1 }] }

      it 'returns file data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.issues' do
    subject(:client_request) do
      client.issues(repository_link: repository.link, access_token: access_token.value)
    end

    before do
      stubs.get('/repos/company_name/repo_name/issues') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'number' => 1 }] }

      it 'returns issues data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end

  describe '.issue_comments' do
    subject(:client_request) do
      client.issue_comments(repository_link: repository.link, access_token: access_token.value, issue_number: 1)
    end

    before do
      stubs.get('/repos/company_name/repo_name/issues/1/comments') { [status, headers, body.to_json] }
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
      let(:body) { [{ 'id' => 1, 'created_at' => DateTime.now.to_s, 'user' => {} }] }

      it 'returns comment data', :aggregate_failures do
        expect(client_request[:success]).to be_truthy
        expect(client_request[:body]).to eq body
      end
    end
  end
end
