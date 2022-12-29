# frozen_string_literal: true

describe Users::RestoreService, type: :service do
  subject(:service_call) { described_class.call(user: user) }

  let!(:user) { create :user }

  before do
    allow(Users::Auth::SendRestoreLinkJob).to receive(:perform_now)
  end

  it 'creates job', :aggregate_failures do
    service_call

    expect(Users::Auth::SendRestoreLinkJob).to have_received(:perform_now).with(id: user.id)
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
