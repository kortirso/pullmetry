# frozen_string_literal: true

describe Import::SyncCompaniesJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:company) { create :company }

  before do
    allow(Import::SyncRepositoriesJob).to receive(:perform_later)
  end

  it 'calls job' do
    job_call

    expect(Import::SyncRepositoriesJob).to have_received(:perform_later).with(id: company.id)
  end
end
