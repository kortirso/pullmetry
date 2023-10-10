# frozen_string_literal: true

describe Import::CompanyService, type: :service do
  subject(:service_call) {
    described_class
      .new(
        sync_repository_from_github: sync_repository_from_github,
        sync_repository_from_gitlab: sync_repository_from_gitlab,
        generate_insights_service: generate_insights_service
      )
      .call(company: company)
  }

  let!(:company) { create :company, accessable: true }
  let!(:repository) { create :repository, company: company, accessable: false, pull_requests_count: 3 }
  let(:sync_repository_from_github) { double }
  let(:sync_repository_from_gitlab) { double }
  let(:generate_insights_service) { double }
  let(:mailer) { double }

  before do
    create :access_token, tokenable: company

    allow(sync_repository_from_github).to receive(:call)
    allow(sync_repository_from_gitlab).to receive(:call)
    allow(generate_insights_service).to receive(:call)

    allow(Users::NotificationMailer).to receive(:repository_access_error_email).and_return(mailer)
    allow(mailer).to receive(:deliver_now)
  end

  it 'calls services and updates company', :aggregate_failures do
    service_call

    expect(sync_repository_from_github).to have_received(:call)
    expect(sync_repository_from_gitlab).not_to have_received(:call)
    expect(generate_insights_service).not_to have_received(:call)
    expect(company.reload.accessable).to be_falsy
    expect(company.not_accessable_ticks).to eq 1
    expect(Users::NotificationMailer).not_to have_received(:repository_access_error_email)
  end

  context 'for over not accessable company' do
    before { company.update!(not_accessable_ticks: described_class::NOT_ACCESSABLE_LIMIT_TICKS - 1) }

    it 'calls insights services and updates repository', :aggregate_failures do
      service_call

      expect(sync_repository_from_github).to have_received(:call)
      expect(sync_repository_from_gitlab).not_to have_received(:call)
      expect(generate_insights_service).not_to have_received(:call)
      expect(company.reload.accessable).to be_falsy
      expect(company.not_accessable_ticks).to eq 10
      expect(Users::NotificationMailer).to have_received(:repository_access_error_email).with(id: company.user_id)
    end
  end

  context 'for accessable repository' do
    before { repository.update(accessable: true) }

    it 'calls insights services and updates repository', :aggregate_failures do
      service_call

      expect(sync_repository_from_github).to have_received(:call)
      expect(sync_repository_from_gitlab).not_to have_received(:call)
      expect(generate_insights_service).to have_received(:call)
      expect(company.reload.accessable).to be_truthy
      expect(company.not_accessable_ticks).to eq 0
      expect(Users::NotificationMailer).not_to have_received(:repository_access_error_email)
    end
  end
end
