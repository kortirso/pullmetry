# frozen_string_literal: true

describe Frontend::Companies::TransfersController do
  describe 'POST#create', skip: 'remove' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:company) { create :company }
      let!(:user) { create :user }

      sign_in_user

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders 404 page' do
          post :create, params: { company_id: company.uuid, user_uuid: 'unexisting' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for user company' do
        before { company.update!(user: @current_user) }

        context 'for user by self' do
          it 'renders 404 page', :aggregate_failures do
            post :create, params: { company_id: company.uuid, user_uuid: @current_user.uuid }

            expect(response).to render_template 'shared/404'
            expect(company.reload.user_id).to eq @current_user.id
          end
        end

        context 'for another target user' do
          it 'updates company', :aggregate_failures do
            post :create, params: { company_id: company.uuid, user_uuid: user.uuid }

            expect(response).to redirect_to companies_path
            expect(company.reload.user_id).to eq user.id
          end

          context 'for unavailable user' do
            before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT + 1, company: company }

            it 'does not update company', :aggregate_failures do
              post :create, params: { company_id: company.uuid, user_uuid: user.uuid }

              expect(response).to redirect_to edit_company_configuration_path(company.uuid)
              expect(company.reload.user_id).to eq @current_user.id
            end
          end
        end
      end
    end

    def do_request
      post :create, params: { company_id: 'unexisting', user_uuid: 'unexisting' }
    end
  end
end
