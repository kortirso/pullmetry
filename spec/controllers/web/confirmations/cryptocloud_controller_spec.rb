# frozen_string_literal: true

describe Web::Confirmations::CryptocloudController do
  describe 'GET#success' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders success page' do
        do_request

        expect(response).to render_template :success
      end
    end

    def do_request
      get :success
    end
  end

  describe 'GET#failure' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders failure page' do
        do_request

        expect(response).to render_template :failure
      end
    end

    def do_request
      get :failure
    end
  end
end
