# frozen_string_literal: true

describe AuthContext::RemoveExpiredUserSessionsJob do
  subject(:job_call) { described_class.perform_now }

  before do
    create :user_session, created_at: DateTime.now - JwtEncoder::EXPIRATION_SECONDS.seconds - 10.seconds
    create :user_session, created_at: DateTime.now
  end

  it 'removes expired sessions' do
    expect { job_call }.to change(User::Session, :count).by(-1)
  end
end
