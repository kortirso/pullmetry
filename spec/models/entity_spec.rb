# frozen_string_literal: true

describe Entity do
  it 'factory should be valid' do
    entity = build :entity

    expect(entity).to be_valid
  end
end
