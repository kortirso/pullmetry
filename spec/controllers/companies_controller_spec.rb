# frozen_string_literal: true

describe CompaniesController do
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

  describe 'GET#new' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders new template' do
        do_request

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { locale: 'en' }
    end
  end

  describe 'GET#edit' do
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
          get :edit, params: { id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user company' do
        before { company.update!(user: @current_user) }

        it 'renders new template' do
          get :edit, params: { id: company.uuid, locale: 'en' }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:request) { do_request }

        it 'does not create company' do
          expect { request }.not_to change(Company, :count)
        end

        it 'redirects to new_company_path' do
          request

          expect(response).to redirect_to new_company_path
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { company: { title: 'Title', name: 'name' }, locale: 'en' } }

        it 'creates company' do
          expect { request }.to change(@current_user.companies, :count).by(1)
        end

        it 'redirects to companies_path' do
          request

          expect(response).to redirect_to companies_path
        end
      end
    end

    def do_request
      post :create, params: { company: { title: '', name: '' }, locale: 'en' }
    end
  end

  describe 'PATCH#update' do
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
          patch :update, params: { id: company.uuid, company: { title: '', name: '' }, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user company' do
        before { company.update!(user: @current_user) }

        context 'for invalid params' do
          let(:request) { patch :update, params: { id: company.uuid, company: { title: '' }, locale: 'en' } }

          it 'does not update company' do
            request

            expect(company.reload.title).not_to eq ''
          end

          it 'redirects to edit_company_path' do
            request

            expect(response).to redirect_to edit_company_path(company.uuid)
          end
        end

        context 'for valid params' do
          let(:request) { patch :update, params: { id: company.uuid, company: { title: 'New title' }, locale: 'en' } }

          it 'updates company' do
            request

            expect(company.reload.title).to eq 'New title'
          end

          it 'redirects to companies_path' do
            request

            expect(response).to redirect_to companies_path
          end
        end
      end
    end

    def do_request
      patch :update, params: { id: 'unexisting', company: { title: '', name: '' }, locale: 'en' }
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

        it 'destroys company' do
          expect { request }.to change(Company, :count).by(-1)
        end

        it 'redirects to companies_path' do
          request

          expect(response).to redirect_to companies_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
