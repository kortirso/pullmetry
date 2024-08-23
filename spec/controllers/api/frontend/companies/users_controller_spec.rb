# frozen_string_literal: true

describe Api::Frontend::Companies::UsersController do
  let!(:user) { create :user }
  let!(:users_session) { create :users_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result] }

  describe 'DELETE#destroy' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      let!(:company) { create :company }
      let!(:companies_user) { create :companies_user }
      let(:request) { delete :destroy, params: { id: companies_user.uuid, pullmetry_access_token: access_token } }

      context 'for company invite' do
        before { companies_user.invite.update!(inviteable: company) }

        context 'for not own invite' do
          it 'does not destroy invite', :aggregate_failures do
            expect { request }.not_to change(Companies::User, :count)
            expect(response).to have_http_status :unauthorized
          end
        end

        context 'for own invite' do
          before { company.update!(user: user) }

          it 'destroys invite', :aggregate_failures do
            expect { request }.to(
              change(Companies::User, :count).by(-1)
                .and(change(Invite, :count).by(-1))
            )
            expect(response).to have_http_status :ok
          end
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
