# frozen_string_literal: true

describe CompaniesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'without companies' do
        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end

      context 'with companies' do
        before do
          create :company
          create :company, user: @current_user
        end

        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end
end
