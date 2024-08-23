# frozen_string_literal: true

describe RemoveUserCommand do
  subject(:command) { instance.call(user: user) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  before do
    create :subscription, user: user
    create :identity, user: user
  end

  it 'destroys specific user details except subscription', :aggregate_failures do
    expect { command }.to change(Identity, :count).by(-1)
    expect(Subscription.count).to eq 1
    expect(User.count).to eq 1
  end
end
