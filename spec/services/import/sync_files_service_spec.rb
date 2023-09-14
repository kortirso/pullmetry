# frozen_string_literal: true

describe Import::SyncFilesService, type: :service do
  subject(:service_call) { described_class.new(pull_request: pull_request).call }

  let!(:pull_request) { create :pull_request }
  let(:fetcher) { double }
  let(:fetch_data) { double }
  let(:data) {
    [
      {
        'status' => 'added',
        'changes' => 1
      },
      {
        'status' => 'modified',
        'changes' => 2
      },
      {
        'status' => 'renamed',
        'changes' => 3
      }
    ]
  }

  before do
    allow(Import::Fetchers::Github::Files).to receive(:new).and_return(fetcher)
    allow(fetcher).to receive(:call).and_return(fetch_data)
    allow(fetch_data).to receive(:result).and_return(data)
  end

  context 'for allowed provider' do
    it 'updates pull request and succeeds', :aggregate_failures do
      expect { service_call }.to change(pull_request, :changed_loc).from(0).to(6)
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for not allowed provider' do
    before { pull_request.repository.update!(provider: Providerable::GITLAB) }

    it 'does not update pull request and succeeds', :aggregate_failures do
      expect { service_call }.not_to change(pull_request, :changed_loc)
      expect(service_call.success?).to be_truthy
    end
  end
end
