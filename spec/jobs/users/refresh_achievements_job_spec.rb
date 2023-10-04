# frozen_string_literal: true

describe Users::RefreshAchievementsJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let(:instance) { Pullmetry::Container['services.persisters.users.refresh_achievements'] }

  before do
    allow(instance).to receive(:call)
  end

  it 'calls service' do
    job_call

    expect(instance).to have_received(:call)
  end
end
