# frozen_string_literal: true

describe Users::RestoreController do
  describe 'GET#new' do
    it 'renders new template' do
      get :new, params: { locale: 'en' }

      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    before { allow(Users::RestoreService).to receive(:call) }

    context 'for unexisting user' do
      it 'redirects to users_restore path' do
        post :create, params: { email: 'unexisting@gmail.com', locale: 'en' }

        expect(response).to redirect_to users_restore_path
      end
    end

    context 'for existing user' do
      let!(:user) { create :user }

      context 'for invalid email' do
        before { post :create, params: { email: 'invalid@gmail.com', locale: 'en' } }

        it 'does not call restore service' do
          expect(Users::RestoreService).not_to have_received(:call)
        end

        it 'redirects to users_restore path' do
          expect(response).to redirect_to users_restore_path
        end
      end

      context 'for valid email' do
        before { post :create, params: { email: user.email.upcase, locale: 'en' } }

        it 'calls restore service' do
          expect(Users::RestoreService).to have_received(:call)
        end

        it 'redirects to users_restore path' do
          expect(response).to redirect_to users_restore_path
        end
      end
    end
  end
end
