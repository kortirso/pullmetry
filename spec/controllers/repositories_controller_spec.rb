# frozen_string_literal: true

describe RepositoriesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      let!(:company) { create :company, user: @current_user }

      context 'without repositories' do
        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end

      context 'with repositories' do
        before do
          create :repository
          create :repository, company: company
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
      let!(:repository) { create :repository }

      sign_in_user

      context 'for not existing repository' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders 404 page' do
          delete :destroy, params: { id: repository.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user company' do
        let(:request) { delete :destroy, params: { id: repository.uuid, locale: 'en' } }

        before { repository.company.update!(user: @current_user) }

        it 'destroys repository and redirects', :aggregate_failures do
          expect { request }.to change(Repository, :count).by(-1)
          expect(response).to redirect_to repositories_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
