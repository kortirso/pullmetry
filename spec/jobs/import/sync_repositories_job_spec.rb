# frozen_string_literal: true

describe Import::SyncRepositoriesJob, type: :service do
  subject(:job_call) { described_class.perform_now(id: company.id) }

  let!(:company) { create :company }

  before do
    allow(Import::SyncRepositoriesService).to receive(:call)
  end

  it 'calls service' do
    job_call

    expect(Import::SyncRepositoriesService).to have_received(:call).with(company: company)
  end
end
