# frozen_string_literal: true

describe RepositoriesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

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

        context 'for specific company' do
          it 'renders index page' do
            get :index, params: { company_id: company.uuid, locale: 'en' }

            expect(response).to render_template :index
          end
        end
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end
end
