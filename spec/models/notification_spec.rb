# frozen_string_literal: true

describe Notification do
  it 'factory should be valid' do
    notification = build :notification

    expect(notification).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:notifyable) }
  end
end
