# frozen_string_literal: true

describe Import::SyncRepositoriesService, type: :service do
  subject(:service_call) {
    described_class
      .new(
        sync_pull_requests_service: sync_pull_requests_service,
        sync_comments_service: sync_comments_service,
        sync_reviews_service: sync_reviews_service,
        sync_files_service: sync_files_service,
        generate_repository_insights_service: generate_repository_insights_service,
        generate_company_insights_service: generate_company_insights_service
      )
      .call(company: company)
  }

  let!(:company) { create :company, accessable: true }
  let!(:repository) { create :repository, company: company, accessable: false, pull_requests_count: 3 }
  let!(:pull_request1) { create :pull_request, repository: repository }
  let!(:pull_request2) { create :pull_request, repository: repository, pull_closed_at: 1.minute.ago }
  let(:sync_pull_requests_service) { double(Import::SyncPullRequestsService) }
  let(:pull_requests_service) { double }
  let(:sync_comments_service) { double(Import::SyncCommentsService) }
  let(:comments_service) { double }
  let(:sync_reviews_service) { double(Import::SyncReviewsService) }
  let(:reviews_service) { double }
  let(:sync_files_service) { double(Import::SyncFilesService) }
  let(:files_service) { double }
  let(:generate_repository_insights_service) { double(Insights::Generate::RepositoryService) }
  let(:generate_company_insights_service) { double(Insights::Generate::CompanyService) }
  let(:mailer) { double }

  before do
    create :access_token, tokenable: company

    allow(sync_pull_requests_service).to receive(:new).and_return(pull_requests_service)
    allow(pull_requests_service).to receive(:call)
    allow(sync_comments_service).to receive(:new).and_return(comments_service)
    allow(comments_service).to receive(:call)
    allow(sync_reviews_service).to receive(:new).and_return(reviews_service)
    allow(reviews_service).to receive(:call)
    allow(sync_files_service).to receive(:new).and_return(files_service)
    allow(files_service).to receive(:call)
    allow(generate_company_insights_service).to receive(:call)
    allow(generate_repository_insights_service).to receive(:call)
    allow(Users::NotificationMailer).to receive(:repository_access_error_email).and_return(mailer)
    allow(mailer).to receive(:deliver_now)
  end

  it 'calls services and updates repository', :aggregate_failures do
    service_call

    expect(sync_pull_requests_service).to have_received(:new).with(repository: repository)
    expect(sync_comments_service).to have_received(:new).with(pull_request: pull_request1)
    expect(sync_reviews_service).to have_received(:new).with(pull_request: pull_request1)
    expect(sync_files_service).to have_received(:new).with(pull_request: pull_request1)
    expect(sync_comments_service).not_to have_received(:new).with(pull_request: pull_request2)
    expect(sync_reviews_service).not_to have_received(:new).with(pull_request: pull_request2)
    expect(sync_files_service).not_to have_received(:new).with(pull_request: pull_request2)
    expect(generate_company_insights_service).not_to have_received(:call)
    expect(generate_repository_insights_service).not_to have_received(:call)
    expect(repository.reload.synced_at).not_to be_nil
    expect(repository.pull_requests_count).to eq 2
    expect(company.reload.accessable).to be_falsy
    expect(company.not_accessable_ticks).to eq 1
    expect(service_call.success?).to be_truthy
    expect(Users::NotificationMailer).not_to have_received(:repository_access_error_email)
  end

  context 'for over not accessable company' do
    before { company.update!(not_accessable_ticks: described_class::NOT_ACCESSABLE_LIMIT_TICKS - 1) }

    it 'calls insights services and updates repository', :aggregate_failures do
      service_call

      expect(repository.reload.synced_at).not_to be_nil
      expect(company.reload.accessable).to be_falsy
      expect(company.not_accessable_ticks).to eq 10
      expect(service_call.success?).to be_truthy
      expect(Users::NotificationMailer).to have_received(:repository_access_error_email).with(id: company.user_id)
    end
  end

  context 'for accessable repository' do
    before { repository.update(accessable: true) }

    it 'calls insights services and updates repository', :aggregate_failures do
      service_call

      expect(generate_repository_insights_service).to have_received(:call).with(insightable: repository)
      expect(generate_company_insights_service).to have_received(:call).with(insightable: company)
      expect(repository.reload.synced_at).not_to be_nil
      expect(company.reload.accessable).to be_truthy
      expect(company.not_accessable_ticks).to eq 0
      expect(service_call.success?).to be_truthy
      expect(Users::NotificationMailer).not_to have_received(:repository_access_error_email)
    end
  end
end
