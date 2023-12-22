# frozen_string_literal: true

describe Achievements::PullRequests::Reviews::RefreshJob, type: :service do
  subject(:job_call) { described_class.perform_now(id: id) }

  let!(:user) { create :user }

  before { allow(Achievement).to receive(:award) }

  context 'for unexisting user' do
    let(:id) { 'unexisting' }

    it 'does not call awarding' do
      job_call

      expect(Achievement).not_to have_received(:award)
    end
  end

  context 'for existing user' do
    let(:id) { user.id }

    it 'calls awarding' do
      job_call

      expect(Achievement).to have_received(:award).with(:review_create, user)
    end
  end
end
