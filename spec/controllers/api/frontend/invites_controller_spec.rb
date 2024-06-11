# frozen_string_literal: true

describe Api::Frontend::InvitesController do
  let!(:user) { create :user }
  let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

  describe 'POST#create' do
    context 'for logged users' do
      let!(:another_user) { create :user }
      let!(:company) { create :company, user: user }

      context 'for invalid company' do
        let(:request) {
          post :create, params: { company_id: company.uuid, invite: { email: '' }, auth_token: access_token }
        }

        before { company.update!(user: another_user) }

        it 'does not create invite', :aggregate_failures do
          expect { request }.not_to change(Invite, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for valid company' do
        context 'for invalid params' do
          let(:request) {
            post :create, params: { company_id: company.uuid, invite: { email: '' }, auth_token: access_token }
          }

          it 'does not create invite', :aggregate_failures do
            expect { request }.not_to change(Invite, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Email must be filled'
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid, invite: { email: 'email@gmail.com' }, auth_token: access_token
            }
          }

          it 'creates invite', :aggregate_failures do
            expect { request }.to change(company.invites, :count).by(1)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end
        end
      end
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      let!(:invite) { create :invite }
      let(:request) { delete :destroy, params: { id: invite.uuid, auth_token: access_token } }

      context 'for user invite' do
        context 'for not own invite' do
          it 'does not destroy invite', :aggregate_failures do
            expect { request }.not_to change(Invite, :count)
            expect(response).to have_http_status :unauthorized
          end
        end

        context 'for own invite' do
          before { invite.update!(inviteable: user) }

          it 'destroys invite', :aggregate_failures do
            expect { request }.to change(Invite, :count).by(-1)
            expect(response).to have_http_status :ok
          end
        end
      end

      context 'for company' do
        let!(:company) { create :company }

        before { invite.update!(inviteable: company) }

        context 'for not own invite' do
          it 'does not destroy invite', :aggregate_failures do
            expect { request }.not_to change(Invite, :count)
            expect(response).to have_http_status :unauthorized
          end
        end

        context 'for own invite' do
          before { company.update!(user: user) }

          it 'destroys invite', :aggregate_failures do
            expect { request }.to change(Invite, :count).by(-1)
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
