# frozen_string_literal: true

describe Frontend::Excludes::GroupsController do
  let!(:user) { create :user }
  let!(:user_session) { create :user_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

  describe 'POST#create' do
    context 'for logged users' do
      let!(:another_user) { create :user }
      let!(:company) { create :company, user: user }

      context 'for invalid company' do
        let(:request) {
          post :create, params: {
            company_id: company.uuid, pullmetry_access_token: access_token
          }
        }

        before { company.update!(user: another_user) }

        it 'does not create group', :aggregate_failures do
          expect { request }.not_to change(Excludes::Group, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for valid company' do
        context 'for valid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              excludes_rules: [{ target: 'title', condition: 'equal', value: 'value' }],
              pullmetry_access_token: access_token
            }
          }

          it 'creates group', :aggregate_failures do
            expect { request }.to change(company.excludes_groups, :count).by(1)
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
      let!(:excludes_group) { create :excludes_group }
      let(:request) { delete :destroy, params: { id: excludes_group.uuid, pullmetry_access_token: access_token } }

      context 'for not user excludes_group' do
        it 'does not destroy excludes_group', :aggregate_failures do
          expect { request }.not_to change(Excludes::Group, :count)
          expect(response).to have_http_status :forbidden
        end
      end

      context 'for user excludes_group' do
        before do
          excludes_group.insightable.update!(user: user)
        end

        it 'destroys excludes_group', :aggregate_failures do
          expect { request }.to change(Excludes::Group, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
