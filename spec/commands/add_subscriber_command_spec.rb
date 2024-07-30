# frozen_string_literal: true

describe AddSubscriberCommand, type: :service do
  subject(:command) { instance.call(params) }

  let!(:instance) { described_class.new }
  let(:mail) { double }

  before do
    allow(SubscribersMailer).to receive(:create_email).and_return(mail)
    allow(mail).to receive(:deliver_later)
  end

  context 'for invalid params' do
    let(:params) { { email: '' } }

    it 'does not create subscriber', :aggregate_failures do
      expect { command }.not_to change(Subscriber, :count)
      expect(command[:errors]).not_to be_blank
      expect(SubscribersMailer).not_to have_received(:create_email)
    end
  end

  context 'for valid params' do
    let(:params) { { email: 'email@gmail.com' } }

    it 'creates subscriber', :aggregate_failures do
      expect { command }.to change(Subscriber, :count).by(1)
      expect(command[:result].is_a?(Subscriber)).to be_truthy
      expect(command[:errors]).to be_blank
      expect(SubscribersMailer).to have_received(:create_email)
    end
  end
end
