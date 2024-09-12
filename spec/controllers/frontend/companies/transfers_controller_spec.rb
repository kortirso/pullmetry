# frozen_string_literal: true

describe Frontend::Companies::TransfersController do
  let!(:user) { create :user }
  let!(:user_session) { create :user_session, user: user }
  let!(:company) { create :company }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

  describe 'POST#create' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      context 'for not existing company' do
        it 'returns not found response' do
          do_request(access_token)

          expect(response).to have_http_status :not_found
        end
      end

      context 'for not existing user company' do
        it 'returns not found response' do
          post :create, params: { company_id: company.uuid, user_uuid: 'unexisting', pullmetry_access_token: access_token }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for user company' do
        let!(:another_user) { create :user }

        before { company.update!(user: user) }

        context 'for user by self' do
          it 'returns not found response', :aggregate_failures do
            post :create, params: { company_id: company.uuid, user_uuid: user.uuid, pullmetry_access_token: access_token }

            expect(response).to have_http_status :not_found
            expect(company.reload.user_id).to eq user.id
          end
        end

        context 'for another target user' do
          it 'updates company', :aggregate_failures do
            post :create, params: { company_id: company.uuid, user_uuid: another_user.uuid, pullmetry_access_token: access_token }

            expect(response).to have_http_status :ok
            expect(company.reload.user_id).to eq another_user.id
          end

          context 'for unavailable user' do
            before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT + 1, company: company }

            it 'does not update company', :aggregate_failures do
              post :create, params: {
                company_id: company.uuid, user_uuid: another_user.uuid, pullmetry_access_token: access_token
              }

              expect(response).to have_http_status :ok
              expect(company.reload.user_id).to eq user.id
            end
          end
        end
      end
    end

    def do_request(access_token=nil)
      post :create, params: { company_id: 'unexisting', user_uuid: 'unexisting', pullmetry_access_token: access_token }
    end
  end
end
