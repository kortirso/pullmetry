# frozen_string_literal: true

describe Admin::RepositoriesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin auth'

    context 'for logged admins' do
      sign_in_admin

      it 'renders index page' do
        do_request

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin auth'

    context 'for logged admins' do
      sign_in_admin

      context 'for unexisting repository' do
        it 'does not destroy repository', :aggregate_failures do
          expect { do_request }.not_to change(Repository, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing repository' do
        let!(:repository) { create :repository }
        let(:request) { delete :destroy, params: { id: repository.id } }

        it 'destroys repository', :aggregate_failures do
          expect { request }.to change(Repository, :count).by(-1)
          expect(response).to redirect_to admin_repositories_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
