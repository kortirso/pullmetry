# frozen_string_literal: true

describe Users::RecoveryController do
  describe 'GET#new' do
    context 'for unexisting user' do
      it 'redirects to users_recovery path' do
        get :new, params: { email: 'unexisting@gmail.com', locale: 'en' }

        expect(response).to redirect_to users_recovery_path(email: 'unexisting@gmail.com')
      end
    end

    context 'for existing user' do
      let!(:user) { create :user }

      context 'for invalid restore_token' do
        it 'redirects to users_recovery path' do
          get :new, params: { email: user.email, restore_token: '123', locale: 'en' }

          expect(response).to redirect_to users_recovery_path(email: user.email, restore_token: '123')
        end
      end

      context 'for valid restore_token' do
        it 'renders new template' do
          get :new, params: { email: user.email, restore_token: user.restore_token, locale: 'en' }

          expect(response).to render_template :new
        end
      end
    end
  end

  describe 'POST#create' do
    context 'for unexisting user' do
      it 'redirects to users_recovery path' do
        post :create, params: { email: 'unexisting@gmail.com', locale: 'en' }

        expect(response).to redirect_to users_recovery_path(email: 'unexisting@gmail.com')
      end
    end

    context 'for existing user' do
      let!(:user) { create :user }

      context 'for invalid restore_token' do
        it 'redirects to users_recovery path' do
          post :create, params: { email: user.email, restore_token: '123', locale: 'en' }

          expect(response).to redirect_to users_recovery_path(email: user.email, restore_token: '123')
        end
      end

      context 'for valid token' do
        context 'for invalid passwords' do
          before do
            post :create, params: {
              email: user.email,
              restore_token: user.restore_token,
              user: { password: '1234567', password_confirmation: '12345678' },
              locale: 'en'
            }
          end

          it 'redirects to users_recovery path' do
            expect(response).to redirect_to users_recovery_path(email: user.email, restore_token: user.restore_token)
          end
        end

        context 'for valid passwords' do
          before do
            post :create, params: {
              email: user.email,
              restore_token: user.restore_token,
              user: { password: '12345678', password_confirmation: '12345678' },
              locale: 'en'
            }
          end

          it 'redirects to users_login path' do
            expect(response).to redirect_to users_login_path
          end
        end
      end
    end
  end
end
