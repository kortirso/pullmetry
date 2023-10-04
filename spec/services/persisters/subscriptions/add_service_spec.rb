# frozen_string_literal: true

describe Persisters::Subscriptions::AddService, type: :service do
  subject(:service_call) { described_class.new.call(user: user, trial: trial) }

  let!(:user) { create :user }

  context 'for trial' do
    let(:trial) { true }

    context 'without subscriptions' do
      it 'creates new subscription', :aggregate_failures do
        expect { service_call }.to change(Subscription, :count).by(1)
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'with subscriptions' do
      before { create :subscription, user: user }

      it 'does not create new subscription', :aggregate_failures do
        expect { service_call }.not_to change(Subscription, :count)
        expect(service_call[:errors]).not_to be_empty
      end
    end

    context 'with parallel requests' do
      before do
        Array.new(3) { Thread.new { described_class.new.call(user: user, trial: trial) } }.each(&:join)
      end

      it 'creates only 1 new subscription' do
        expect(Subscription.count).to eq 1
      end
    end
  end
end
