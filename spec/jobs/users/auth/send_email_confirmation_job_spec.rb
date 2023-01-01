# frozen_string_literal: true

describe Users::Auth::SendEmailConfirmationJob, type: :service do
  subject(:job_call) { described_class.perform_now(id: user.id) }

  let!(:user) { create :user }
  let(:mailer) { double }

  before do
    allow(Users::AuthMailer).to receive(:confirmation_email).and_return(mailer)
    allow(mailer).to receive(:deliver_now)
  end

  it 'calls service', :aggregate_failures do
    job_call

    expect(Users::AuthMailer).to have_received(:confirmation_email).with(id: user.id)
    expect(mailer).to have_received(:deliver_now)
  end
end
