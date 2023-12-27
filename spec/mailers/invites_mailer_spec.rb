# frozen_string_literal: true

describe InvitesMailer do
  describe '.create_email' do
    subject(:delivery) { mail.deliver_now }

    let(:mail) { described_class.create_email(id: invite_id) }
    let!(:invite) { create :invite, email: 'email' }

    context 'when user is not exist' do
      let(:invite_id) { 'unexisting' }

      it 'does not send email' do
        expect { delivery }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context 'when user exists' do
      let(:invite_id) { invite.id }

      it 'sends email' do
        expect { delivery }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end
