# frozen_string_literal: true

describe Users::CompleteService, type: :service do
  subject(:service_call) { described_class.call(user: user) }

  let!(:user) { create :user, confirmation_token: '123' }

  it 'resets confirmation token', :aggregate_failures do
    service_call

    expect(user.reload.confirmation_token).to be_nil
    expect(user.confirmed_at).not_to be_nil
  end

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end
end
