# frozen_string_literal: true

describe Users::SessionsController do
  describe 'GET#new' do
    it 'renders new template' do
      get :new, params: { locale: 'en' }

      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    context 'for unexisting user' do
      it 'renders new template' do
        post :create, params: { user: { email: 'unexisting@gmail.com', password: '1' }, locale: 'en' }

        expect(response).to render_template :new
      end
    end

    context 'for existing user' do
      let(:user) { create :user }

      context 'for invalid password' do
        it 'renders new template' do
          post :create, params: { user: { email: user.email, password: 'invalid_password' }, locale: 'en' }

          expect(response).to render_template :new
        end
      end

      context 'for empty password' do
        it 'renders new template' do
          post :create, params: { user: { email: user.email, password: '' }, locale: 'en' }

          expect(response).to render_template :new
        end
      end

      context 'for valid password' do
        it 'redirects to dashboard path' do
          post :create, params: { user: { email: user.email, password: user.password }, locale: 'en' }

          expect(response).to redirect_to root_path
        end
      end

      context 'for valid password and upcased email' do
        it 'redirects to dashboard path' do
          post :create, params: { user: { email: user.email.upcase, password: user.password }, locale: 'en' }

          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe 'GET#destroy' do
    it 'redirects to root path' do
      get :destroy, params: { locale: 'en' }

      expect(response).to redirect_to root_path
    end
  end
end
