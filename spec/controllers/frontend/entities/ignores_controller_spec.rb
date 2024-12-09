# frozen_string_literal: true

describe Frontend::Entities::IgnoresController do
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
            company_id: company.id, entity_ignore: { entity_value: '' }, pullmetry_access_token: access_token
          }
        }

        before { company.update!(user: another_user) }

        it 'does not create ignore', :aggregate_failures do
          expect { request }.not_to change(Entity::Ignore, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for valid company' do
        context 'for invalid params' do
          let(:request) {
            post :create, params: {
              company_id: company.id, entity_ignore: { entity_value: '' }, pullmetry_access_token: access_token
            }
          }

          it 'does not create ignore', :aggregate_failures do
            expect { request }.not_to change(Entity::Ignore, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Entity value must be filled'
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              company_id: company.id, entity_ignore: { entity_value: 'value' }, pullmetry_access_token: access_token
            }
          }

          it 'creates ignore', :aggregate_failures do
            expect { request }.to change(company.entity_ignores, :count).by(1)
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
      let!(:ignore) { create :ignore }
      let(:request) { delete :destroy, params: { id: ignore.id, pullmetry_access_token: access_token } }

      context 'for not user ignore' do
        it 'does not destroy ignore', :aggregate_failures do
          expect { request }.not_to change(Entity::Ignore, :count)
          expect(response).to have_http_status :forbidden
        end
      end

      context 'for user ignore' do
        before { ignore.insightable.update!(user: user) }

        it 'destroys ignore', :aggregate_failures do
          expect { request }.to change(Entity::Ignore, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
