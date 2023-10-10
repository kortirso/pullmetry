# frozen_string_literal: true

describe Import::Synchronizers::Repositories::Github, type: :service do
  subject(:service_call) { instance.call(repository: repository) }

  let!(:instance) { described_class.new }
  let!(:repository) { create :repository, accessable: false, pull_requests_count: 3 }
  let(:insights_service) { double }

  before do
    create :pull_request, repository: repository
    create :pull_request, repository: repository, pull_closed_at: 1.minute.ago

    allow(Pullmetry::Container.resolve('services.import.synchronizers.pull_requests.github')).to receive(:call)
    allow(Pullmetry::Container.resolve('services.import.synchronizers.comments.github')).to receive(:call)
    allow(Pullmetry::Container.resolve('services.import.synchronizers.reviews.github')).to receive(:call)
    allow(Pullmetry::Container.resolve('services.import.synchronizers.files.github')).to receive(:call)

    allow(Insights::Generate::RepositoryService).to receive(:new).and_return(insights_service)
    allow(insights_service).to receive(:call)
  end

  it 'calls services and updates repository', :aggregate_failures do
    service_call

    expect(repository.pull_requests_count).to eq 2
    expect(repository.reload.synced_at).not_to be_nil
    expect(insights_service).not_to have_received(:call)
  end

  context 'for accessable repository' do
    before { repository.update(accessable: true) }

    it 'calls insights services and updates repository', :aggregate_failures do
      service_call

      expect(repository.pull_requests_count).to eq 2
      expect(repository.reload.synced_at).not_to be_nil
      expect(insights_service).to have_received(:call).with(insightable: repository)
    end
  end
end
