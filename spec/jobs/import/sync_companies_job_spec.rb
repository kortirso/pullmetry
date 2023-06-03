# frozen_string_literal: true

describe Import::SyncCompaniesJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:company) { create :company }

  before do
    allow(Import::SyncRepositoriesJob).to receive(:perform_later)
    allow(Export::Slack::Reports::Jobs::SendService).to receive(:call)
  end

  it 'calls job', :aggregate_failures do
    job_call

    expect(Import::SyncRepositoriesJob).to have_received(:perform_later).with(id: company.id)
    expect(Export::Slack::Reports::Jobs::SendService).to have_received(:call)
  end
end
