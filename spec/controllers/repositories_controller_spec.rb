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

      context 'if user does not use repositories limit' do
        it 'renders new template' do
          do_request

          expect(response).to render_template :new
        end
      end

      context 'if user has use repositories limit' do
        let!(:company) { create :company, user: @current_user }

        before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT, company: company }

        context 'for regular user' do
          it 'renders access denied' do
            do_request

            expect(response).to render_template 'shared/access'
          end
        end

        context 'for premium user' do
          before { create :subscription, user: @current_user, start_time: 1.day.ago, end_time: 1.day.after }

          it 'renders new template' do
            do_request

            expect(response).to render_template :new
          end
        end
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
              repository: { company_uuid: 'unexisting', title: '', link: '' }, locale: 'en'
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
              repository: { company_uuid: company.uuid, title: 'Title', link: 'nam' }, locale: 'en'
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

        context 'for invalid params' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: '', link: '' }, locale: 'en'
            }
          }

          before { company.update!(user: @current_user) }

          it 'does not create repository' do
            expect { request }.not_to change(company.repositories, :count)
          end

          it 'redirects to new_repository_path' do
            request

            expect(response).to redirect_to new_repository_path
          end
        end

        context 'for invalid external_id' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', link: 'link', provider: 'gitlab' }, locale: 'en'
            }
          }

          before { company.update!(user: @current_user) }

          it 'does not create repository' do
            expect { request }.not_to change(company.repositories, :count)
          end

          it 'redirects to new_repository_path' do
            request

            expect(response).to redirect_to new_repository_path
          end
        end

        context 'for valid params with external id' do
          let(:request) {
            post :create, params: {
              repository: {
                company_uuid: company.uuid, title: 'Title', link: 'nam', provider: 'gitlab', external_id: '1'
              },
              locale: 'en'
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

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', link: 'nam', provider: 'github' }, locale: 'en'
            }
          }

          before { company.update!(user: @current_user) }

          context 'if user does not use repositories limit' do
            it 'creates repository' do
              expect { request }.to change(company.repositories, :count).by(1)
            end

            it 'redirects to repositories_path' do
              request

              expect(response).to redirect_to repositories_path
            end
          end

          context 'if user uses repositories limit' do
            before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT, company: company }

            it 'does not create repository' do
              expect { request }.not_to change(company.repositories, :count)
            end

            it 'renders access denied' do
              request

              expect(response).to render_template 'shared/access'
            end
          end
        end
      end
    end

    def do_request
      post :create, params: { repository: { company_uuid: 'unexisting', title: '', link: '' }, locale: 'en' }
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
