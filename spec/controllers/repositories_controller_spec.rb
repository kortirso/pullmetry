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

  describe 'POST#create' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:request) { do_request }

        it 'does not create repository' do
          expect { request }.not_to change(Repository, :count)
        end

        it 'redirects to new_repository_path' do
          request

          expect(response).to redirect_to new_repository_path
        end
      end

      context 'with company' do
        let!(:company) { create :company }

        context 'for not existing company' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: 'unexisting', title: '', name: '' }, locale: 'en'
            }
          }

          it 'does not create repository' do
            expect { request }.not_to change(Repository, :count)
          end

          it 'redirects to new_repository_path' do
            request

            expect(response).to redirect_to new_repository_path
          end
        end

        context 'for existing not user company' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', name: 'nam' }, locale: 'en'
            }
          }

          it 'does not create repository' do
            expect { request }.not_to change(Repository, :count)
          end

          it 'redirects to new_repository_path' do
            request

            expect(response).to redirect_to new_repository_path
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', name: 'nam' }, locale: 'en'
            }
          }

          before { company.update!(user: @current_user) }

          it 'creates repository' do
            expect { request }.to change(company.repositories, :count).by(1)
          end

          it 'redirects to repositories_path' do
            request

            expect(response).to redirect_to repositories_path
          end
        end
      end
    end

    def do_request
      post :create, params: { repository: { company_uuid: 'unexisting', title: '', name: '' }, locale: 'en' }
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

        it 'destroys repository' do
          expect { request }.to change(Repository, :count).by(-1)
        end

        it 'redirects to repositories_path' do
          request

          expect(response).to redirect_to repositories_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
