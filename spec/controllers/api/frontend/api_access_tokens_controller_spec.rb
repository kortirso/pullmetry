# frozen_string_literal: true

describe Api::Frontend::ApiAccessTokensController do
  let!(:user) { create :user }
  let!(:users_session) { create :users_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result] }

  describe 'POST#create' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      let(:request) { post :create, params: { pullmetry_access_token: access_token } }

      it 'creates api access token', :aggregate_failures do
        expect { request }.to change(user.api_access_tokens, :count).by(1)
        expect(response).to have_http_status :ok
        expect(response.parsed_body['errors']).to be_nil
      end
    end

    def do_request
      post :create, params: {}
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      let!(:api_access_token) { create :api_access_token }

      context 'for unexisting api access token' do
        let(:request) { delete :destroy, params: { id: 'unexisting', pullmetry_access_token: access_token } }

        it 'does not destroy api access token', :aggregate_failures do
          expect { request }.not_to change(ApiAccessToken, :count)
          expect(response).to have_http_status :not_found
        end
      end

      context 'for not own api access token' do
        let(:request) { delete :destroy, params: { id: api_access_token.uuid, pullmetry_access_token: access_token } }

        it 'does not destroy api access token', :aggregate_failures do
          expect { request }.not_to change(ApiAccessToken, :count)
          expect(response).to have_http_status :not_found
        end
      end

      context 'for own api access token' do
        let(:request) { delete :destroy, params: { id: api_access_token.uuid, pullmetry_access_token: access_token } }

        before { api_access_token.update!(user: user) }

        it 'destroys api access token', :aggregate_failures do
          expect { request }.to change(ApiAccessToken, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
