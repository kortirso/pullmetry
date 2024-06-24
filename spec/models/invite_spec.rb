# frozen_string_literal: true

describe Invite do
  it 'factory should be valid' do
    invite = build :invite

    expect(invite).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:inviteable) }
    it { is_expected.to belong_to(:receiver).class_name('::User').optional }
    it { is_expected.to have_many(:companies_users).class_name('Companies::User').dependent(:destroy) }
  end
end
