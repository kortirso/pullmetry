# frozen_string_literal: true

describe Webhook do
  it 'factory should be valid' do
    webhook = build :webhook

    expect(webhook).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:webhookable) }
  end
end
