# frozen_string_literal: true

describe Web::CompaniesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'

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

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:company) { create :company }

      sign_in_user

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders 404 page' do
          delete :destroy, params: { id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user company' do
        let(:request) { delete :destroy, params: { id: company.uuid, locale: 'en' } }

        before { company.update!(user: @current_user) }

        it 'destroys company and redirects', :aggregate_failures do
          expect { request }.to change(Company, :count).by(-1)
          expect(response).to redirect_to companies_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
