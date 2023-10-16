# frozen_string_literal: true

describe Import::SyncCompaniesJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:company) { create :company }
  let(:delivery_service) { double }

  before do
    allow(Import::SyncRepositoriesJob).to receive(:perform_later)

    allow(AdminDelivery).to receive(:with).and_return(delivery_service)
    allow(delivery_service).to receive(:job_execution_report).and_return(delivery_service)
    allow(delivery_service).to receive(:deliver_later)
  end

  it 'calls job', :aggregate_failures do
    job_call

    expect(Import::SyncRepositoriesJob).to have_received(:perform_later).with(id: company.id)
    expect(AdminDelivery).to have_received(:with)
  end
end
