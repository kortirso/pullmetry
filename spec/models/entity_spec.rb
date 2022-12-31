# frozen_string_literal: true

describe Entity do
  it 'factory should be valid' do
    entity = build :entity

    expect(entity).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:pull_requests_entities).class_name('::PullRequests::Entity').dependent(:destroy) }
    it { is_expected.to have_many(:pull_requests).through(:pull_requests_entities) }
    it { is_expected.to have_many(:insights).dependent(:destroy) }
  end
end
