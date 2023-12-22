# frozen_string_literal: true

describe Users::RefreshAchievementsJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:user) { create :user }

  before do
    allow(Achievements::PullRequests::Comments::RefreshJob).to receive(:perform_later)
    allow(Achievements::PullRequests::Reviews::RefreshJob).to receive(:perform_later)
    allow(Achievements::PullRequests::RefreshJob).to receive(:perform_later)
  end

  it 'calls other jobs', :aggregate_failures do
    job_call

    expect(Achievements::PullRequests::Comments::RefreshJob).to have_received(:perform_later).with(id: user.id)
    expect(Achievements::PullRequests::Reviews::RefreshJob).to have_received(:perform_later).with(id: user.id)
    expect(Achievements::PullRequests::RefreshJob).to have_received(:perform_later).with(id: user.id)
  end
end
