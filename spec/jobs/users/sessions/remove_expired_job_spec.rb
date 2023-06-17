# frozen_string_literal: true

describe Users::Sessions::RemoveExpiredJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  before do
    create :users_session, created_at: DateTime.now - JwtEncoder::EXPIRATION_SECONDS.seconds - 10.seconds
    create :users_session, created_at: DateTime.now
  end

  it 'removes expired sessions' do
    expect { job_call }.to change(Users::Session, :count).by(-1)
  end
end
