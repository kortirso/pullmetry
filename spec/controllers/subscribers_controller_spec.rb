# frozen_string_literal: true

describe SubscribersController do
  describe 'POST#create' do
    context 'for double subscribing' do
      let(:request) { post :create, params: { subscriber: { email: 'email' } } }

      before do
        cookies[:pullmetry_subscriber_email] = {
          value: 'email',
          expires: 1.month.from_now
        }
      end

      it 'redirects to root path', :aggregate_failures do
        expect { request }.not_to change(Subscriber, :count)
        expect(response).to redirect_to root_path
        expect(cookies[:pullmetry_subscriber_email]).not_to be_nil
      end
    end

    context 'for existing subscriber' do
      let(:request) { post :create, params: { subscriber: { email: 'subscriber@gmail.com' } } }

      before { create :subscriber, email: 'subscriber@gmail.com' }

      it 'redirects to root path', :aggregate_failures do
        expect { request }.not_to change(Subscriber, :count)
        expect(response).to redirect_to root_path
        expect(cookies[:pullmetry_subscriber_email]).to be_nil
      end
    end

    context 'for invalid email' do
      let(:request) { post :create, params: { subscriber: { email: 'subscriber' } } }

      it 'redirects to root path', :aggregate_failures do
        expect { request }.not_to change(Subscriber, :count)
        expect(response).to redirect_to root_path
        expect(cookies[:pullmetry_subscriber_email]).to be_nil
      end
    end

    context 'for valid email' do
      let(:request) { post :create, params: { subscriber: { email: 'subscriber@gmail.com' } } }

      it 'redirects to root path', :aggregate_failures do
        expect { request }.to change(Subscriber, :count).by(1)
        expect(response).to redirect_to root_path
        expect(cookies[:pullmetry_subscriber_email]).not_to be_nil
      end
    end
  end
end
