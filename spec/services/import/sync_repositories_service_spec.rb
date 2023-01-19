# frozen_string_literal: true

describe Import::SyncRepositoriesService, type: :service do
  subject(:service_call) {
    described_class
      .new(
        sync_pull_requests_service: sync_pull_requests_service,
        sync_comments_service: sync_comments_service,
        sync_reviews_service: sync_reviews_service,
        generate_insights_service: generate_insights_service
      )
      .call(company: company)
  }

  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }
  let!(:pull_request) { create :pull_request, repository: repository }
  let(:sync_pull_requests_service) { double(Import::SyncPullRequestsService) }
  let(:pull_requests_service) { double }
  let(:sync_comments_service) { double(Import::SyncCommentsService) }
  let(:comments_service) { double }
  let(:sync_reviews_service) { double(Import::SyncReviewsService) }
  let(:reviews_service) { double }
  let(:generate_insights_service) { double(Insights::GenerateService) }

  before do
    allow(sync_pull_requests_service).to receive(:new).and_return(pull_requests_service)
    allow(pull_requests_service).to receive(:call)
    allow(sync_comments_service).to receive(:new).and_return(comments_service)
    allow(comments_service).to receive(:call)
    allow(sync_reviews_service).to receive(:new).and_return(reviews_service)
    allow(reviews_service).to receive(:call)
    allow(generate_insights_service).to receive(:call)
  end

  it 'calls services', :aggregate_failures do
    service_call

    expect(sync_pull_requests_service).to have_received(:new).with(repository: repository)
    expect(sync_comments_service).to have_received(:new).with(pull_request: pull_request)
    expect(sync_reviews_service).to have_received(:new).with(pull_request: pull_request)
    expect(generate_insights_service).to have_received(:call).with(insightable: repository)
    expect(generate_insights_service).to have_received(:call).with(insightable: company)
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
