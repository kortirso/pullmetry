# frozen_string_literal: true

describe Admin::Companies::RepositoriesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin auth'

    context 'for logged admins' do
      sign_in_admin

      context 'for unexisting company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing company' do
        let(:company) { create :company }

        it 'renders index page' do
          get :index, params: { company_id: company.id }

          expect(response).to render_template 'admin/repositories/index'
        end
      end
    end

    def do_request
      get :index, params: { company_id: 'unexisting' }
    end
  end
end
