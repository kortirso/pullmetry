# frozen_string_literal: true

describe Frontend::AccessTokensController do
  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }
  let!(:user) { create :user }
  let!(:user_session) { create :user_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

  describe 'POST#create' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      context 'for company type' do
        context 'for unexisting company' do
          let(:request) do
            post :create, params: { company_id: 'unexisting', access_token: { value: '' }, pullmetry_access_token: access_token }
          end

          it 'does not create access token', :aggregate_failures do
            expect { request }.not_to change(AccessToken, :count)
            expect(response).to have_http_status :not_found
            expect(response.parsed_body['errors']).not_to be_nil
          end
        end

        context 'for existing company' do
          let(:request) do
            post :create, params: { company_id: company.uuid, access_token: { value: '' }, pullmetry_access_token: access_token }
          end

          before { company.update!(user: user) }

          context 'for invalid params' do
            it 'does not create access token', :aggregate_failures do
              expect { request }.not_to change(AccessToken, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body['errors']).not_to be_nil
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: {
                company_id: company.uuid,
                access_token: {
                  value: 'github_pat_*****_******',
                  expired_at: '2024-01-31 13:45'
                },
                pullmetry_access_token: access_token
              }
            }

            it 'creates access token', :aggregate_failures do
              request

              expect(AccessToken.where(tokenable: company).size).to eq 1
              expect(AccessToken.last.expired_at).to eq DateTime.new(2024, 1, 31, 13, 45)
              expect(response).to have_http_status :ok
            end
          end
        end
      end

      context 'for repository type' do
        context 'for unexisting repository' do
          let(:request) do
            post :create, params: {
              repository_id: 'unexisting', access_token: { value: '' }, pullmetry_access_token: access_token
            }
          end

          it 'does not create access token', :aggregate_failures do
            expect { request }.not_to change(AccessToken, :count)
            expect(response).to have_http_status :not_found
            expect(response.parsed_body['errors']).not_to be_nil
          end
        end

        context 'for existing repository' do
          let(:request) do
            post :create, params: {
              repository_id: repository.uuid, access_token: { value: '' }, pullmetry_access_token: access_token
            }
          end

          before { company.update!(user: user) }

          context 'for invalid params' do
            it 'does not create access token', :aggregate_failures do
              expect { request }.not_to change(AccessToken, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body['errors']).not_to be_nil
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: {
                repository_id: repository.uuid,
                access_token: {
                  value: 'github_pat_*****_******',
                  expired_at: '2024-01-31 13:45'
                },
                pullmetry_access_token: access_token
              }
            }

            it 'creates access token', :aggregate_failures do
              request

              expect(AccessToken.where(tokenable: repository).size).to eq 1
              expect(AccessToken.last.expired_at).to eq DateTime.new(2024, 1, 31, 13, 45)
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      post :create, params: { company_id: 'unexisting', access_token: { value: '' } }
    end
  end
end
