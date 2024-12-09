# frozen_string_literal: true

describe Web::Companies::RepositoriesController do
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

      context 'for existing company where user has insights' do
        before do
          identity = create :identity, user: @current_user
          entity = create :entity, identity: identity
          create :insight, insightable: company, entity: entity
        end

        it 'renders index page' do
          get :index, params: { company_id: company.id, locale: 'en' }

          expect(response).to render_template 'repositories/index'
        end
      end

      context 'for existing company' do
        before { company.update!(user: @current_user) }

        context 'without repositories' do
          it 'renders index page' do
            get :index, params: { company_id: company.id, locale: 'en' }

            expect(response).to render_template 'repositories/index'
          end
        end

        context 'with repositories' do
          before do
            create :repository
            create :repository, company: company
          end

          it 'renders index page' do
            get :index, params: { company_id: company.id, locale: 'en' }

            expect(response).to render_template 'repositories/index'
          end
        end
      end
    end

    def do_request
      get :index, params: { company_id: 'unexisting', locale: 'en' }
    end
  end
end
