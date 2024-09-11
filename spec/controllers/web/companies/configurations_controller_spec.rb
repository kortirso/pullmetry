# frozen_string_literal: true

describe Web::Companies::ConfigurationsController do
  describe 'GET#edit' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:company) { create :company }

      sign_in_user

      before do
        group = create :excludes_group, insightable: company
        create :excludes_rule, excludes_group: group
        webhook = create :webhook, company: company
        create :notification, notifyable: company, webhook: webhook
      end

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders access page' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/access'
        end
      end

      context 'for existing company with user read access' do
        before do
          identity = create :identity, user: @current_user
          entity = create :entity, identity: identity
          create :insight, insightable: company, entity: entity
        end

        it 'renders access page' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/access'
        end
      end

      context 'for existing user company' do
        before { company.update!(user: @current_user) }

        it 'renders new template' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { company_id: 'unexisting', locale: 'en' }
    end
  end
end
