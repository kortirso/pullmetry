# frozen_string_literal: true

describe Subscriber do
  it 'factory should be valid' do
    subscriber = build :subscriber

    expect(subscriber).to be_valid
  end
end
