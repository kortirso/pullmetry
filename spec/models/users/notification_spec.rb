# frozen_string_literal: true

describe Users::Notification do
  it 'factory should be valid' do
    users_notification = build :users_notification

    expect(users_notification).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).class_name('::User') }
  end
end
