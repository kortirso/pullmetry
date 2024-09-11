# frozen_string_literal: true

describe WorkTime do
  it 'factory should be valid' do
    work_time = build :work_time

    expect(work_time).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:worktimeable) }
  end
end
