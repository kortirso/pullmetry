# frozen_string_literal: true

describe Feedback do
  it 'factory should be valid' do
    feedback = build :feedback

    expect(feedback).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
