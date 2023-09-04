# frozen_string_literal: true

describe Users::NotificationMailer do
  describe '.repository_access_error_email' do
    subject(:delivery) { mail.deliver_now }

    let(:mail) { described_class.repository_access_error_email(id: user_id) }
    let!(:user) { create :user }

    context 'when user is not exist' do
      let(:user_id) { 'unexisting' }

      it 'does not send email' do
        expect { delivery }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context 'when user exists' do
      let(:user_id) { user.id }

      context 'when user does not want to receive email' do
        it 'does not send email' do
          expect { delivery }.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end

      context 'when user wants to receive email' do
        before { create :users_notification, user: user, value: true }

        it 'sends email' do
          expect { delivery }.to change(ActionMailer::Base.deliveries, :count).by(1)
        end
      end
    end
  end
end
