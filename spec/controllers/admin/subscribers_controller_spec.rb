# frozen_string_literal: true

describe Admin::SubscribersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin auth'

    context 'for logged admins' do
      sign_in_admin

      context 'without subscribers' do
        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end

      context 'with subscribers' do
        before { create :subscriber }

        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index
    end
  end
end
