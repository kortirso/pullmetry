# frozen_string_literal: true

describe Subscribers::UnsubscribesController do
  describe 'GET#show' do
    context 'for unexisting subscriber' do
      let(:request) { get :show, params: { email: '', unsubscribe_token: '' } }

      it 'redirects to root path' do
        request

        expect(response).to redirect_to root_path
      end
    end

    context 'for existing subscriber' do
      let!(:subscriber) { create :subscriber }

      context 'for invalid token' do
        let(:request) { get :show, params: { email: subscriber.email, unsubscribe_token: '' } }

        it 'redirects to root path', :aggregate_failures do
          request

          expect(subscriber.reload.unsubscribe_token).not_to be_nil
          expect(response).to redirect_to root_path
        end
      end

      context 'for valid token' do
        let(:request) do
          get :show, params: { email: subscriber.email, unsubscribe_token: subscriber.unsubscribe_token }
        end

        it 'renders show page', :aggregate_failures do
          request

          expect(subscriber.reload.unsubscribe_token).to be_nil
          expect(response).to render_template :show
        end
      end
    end
  end
end
