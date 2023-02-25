# frozen_string_literal: true

describe Users::RefreshAchievementsJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  before do
    allow(Users::RefreshAchievementsService).to receive(:call)
  end

  it 'calls service' do
    job_call

    expect(Users::RefreshAchievementsService).to have_received(:call)
  end
end
