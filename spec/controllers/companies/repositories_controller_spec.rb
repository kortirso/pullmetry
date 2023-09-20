# frozen_string_literal: true

describe Companies::RepositoriesController do
  let!(:company) { create :company }

  describe 'GET#index' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for unexisting company' do
        it 'renders access denied' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing company' do
        before { company.update!(user: @current_user) }

        context 'without repositories' do
          it 'renders index page' do
            get :index, params: { company_id: company.uuid, locale: 'en' }

            expect(response).to render_template 'repositories/index'
          end
        end

        context 'with repositories' do
          before do
            create :repository
            create :repository, company: company
          end

          it 'renders index page' do
            get :index, params: { company_id: company.uuid, locale: 'en' }

            expect(response).to render_template 'repositories/index'
          end
        end
      end
    end

    def do_request
      get :index, params: { company_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for unexisting company' do
        it 'renders access denied' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing company' do
        let(:request) { get :new, params: { company_id: company.uuid, locale: 'en' } }

        before { company.update!(user: @current_user) }

        context 'if user does not use repositories limit' do
          it 'renders new template' do
            request

            expect(response).to render_template 'repositories/new'
          end
        end

        context 'if user has use repositories limit' do
          before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT, company: company }

          context 'for regular user' do
            it 'renders access denied' do
              request

              expect(response).to render_template 'shared/access'
            end
          end

          context 'for premium user' do
            before { create :subscription, user: @current_user, start_time: 1.day.ago, end_time: 1.day.after }

            it 'renders new template' do
              request

              expect(response).to render_template 'repositories/new'
            end
          end
        end
      end
    end

    def do_request
      get :new, params: { company_id: 'unexisting', locale: 'en' }
    end
  end
end
