# frozen_string_literal: true

describe Web::Subscriptions::TrialController do
  describe 'GET#create' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for unexisting subscription' do
        it 'creates subscription and redirects', :aggregate_failures do
          expect { do_request }.to change(User::Subscription, :count).by(1)
          expect(response).to redirect_to profile_path
        end
      end

      context 'for existing subscription' do
        before { create :user_subscription, user: @current_user }

        it 'does not create subscription and redirects', :aggregate_failures do
          expect { do_request }.not_to change(User::Subscription, :count)
          expect(response).to redirect_to profile_path
        end
      end
    end

    def do_request
      get :create, params: { locale: 'en' }
    end
  end
end
