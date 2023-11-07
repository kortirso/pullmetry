# frozen_string_literal: true

describe SlackWebhooks::Admin::FeedbackCreatedPayload, type: :service do
  subject(:service_call) { described_class.new.call(id: feedback.id) }

  let!(:feedback) { create :feedback }

  it 'succeeds' do
    expect(service_call[:blocks].size).to eq 3
  end
end
