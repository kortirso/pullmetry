# frozen_string_literal: true

describe SubscribersMailer do
  describe '.create_email' do
    subject(:delivery) { mail.deliver_now }

    let(:mail) { described_class.create_email(id: subscriber_id) }
    let!(:subscriber) { create :subscriber, email: 'email@gmail.com' }

    context 'when subscriber is not exist' do
      let(:subscriber_id) { 'unexisting' }

      it 'does not send email' do
        expect { delivery }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context 'when subscriber exists' do
      let(:subscriber_id) { subscriber.id }

      it 'sends email' do
        expect { delivery }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end
