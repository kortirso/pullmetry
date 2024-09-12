# frozen_string_literal: true

describe AddUserSubscriptionCommand, type: :service do
  subject(:service_call) { instance.call(user: user, trial: trial) }

  let!(:user) { create :user }
  let(:instance) { described_class.new }

  context 'for trial' do
    let(:trial) { true }

    context 'without subscriptions' do
      it 'creates new subscription', :aggregate_failures do
        expect { service_call }.to change(User::Subscription, :count).by(1)
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'with subscriptions' do
      before { create :user_subscription, user: user }

      it 'does not create new subscription', :aggregate_failures do
        expect { service_call }.not_to change(User::Subscription, :count)
        expect(service_call[:errors]).not_to be_empty
      end
    end

    context 'with parallel requests' do
      before do
        Array.new(3) { Thread.new { instance.call(user: user, trial: trial) } }.each(&:join)
      end

      it 'creates only 1 new subscription' do
        expect(User::Subscription.count).to eq 1
      end
    end
  end
end
