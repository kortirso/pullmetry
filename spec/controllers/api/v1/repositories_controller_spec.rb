# frozen_string_literal: true

describe Api::V1::RepositoriesController do
  describe 'POST#create' do
    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for invalid params' do
        let(:request) {
          post :create, params: {
            repository: { company_uuid: 'unexisting', title: '', link: '' },
            auth_token: access_token
          }
        }

        it 'does not create repository and redirects', :aggregate_failures do
          expect { request }.not_to change(Repository, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).not_to be_nil
        end
      end

      context 'with company' do
        let!(:company) { create :company }

        context 'for not existing company' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: 'unexisting', title: '', link: '' }, auth_token: access_token
            }
          }

          it 'does not create repository and redirects', :aggregate_failures do
            expect { request }.not_to change(Repository, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).not_to be_nil
          end
        end

        context 'for existing not user company' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', link: 'nam' }, auth_token: access_token
            }
          }

          it 'does not create repository and redirects', :aggregate_failures do
            expect { request }.not_to change(Repository, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).not_to be_nil
          end
        end

        context 'for invalid params' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: '', link: '' }, auth_token: access_token
            }
          }

          before { company.update!(user: user) }

          it 'does not create repository and redirects', :aggregate_failures do
            expect { request }.not_to change(company.repositories, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).not_to be_nil
          end
        end

        context 'for invalid external_id' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', link: 'link', provider: 'gitlab' },
              auth_token: access_token
            }
          }

          before { company.update!(user: user) }

          it 'does not create repository and redirects', :aggregate_failures do
            expect { request }.not_to change(company.repositories, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).not_to be_nil
          end
        end

        context 'for valid params with external id' do
          let(:request) {
            post :create, params: {
              repository: {
                company_uuid: company.uuid, title: 'Title', link: 'nam', provider: 'gitlab', external_id: '1'
              }, auth_token: access_token
            }
          }

          before { company.update!(user: user) }

          it 'creates repository and redirects', :aggregate_failures do
            expect { request }.to change(company.repositories, :count).by(1)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              repository: { company_uuid: company.uuid, title: 'Title', link: 'nam', provider: 'github' },
              auth_token: access_token
            }
          }

          before { company.update!(user: user) }

          context 'if user does not use repositories limit' do
            it 'creates repository and redirects', :aggregate_failures do
              expect { request }.to change(company.repositories, :count).by(1)
              expect(response).to have_http_status :ok
              expect(response.parsed_body['errors']).to be_nil
            end
          end

          context 'if user uses repositories limit' do
            before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT, company: company }

            it 'does not create repository and redirects', :aggregate_failures do
              expect { request }.not_to change(company.repositories, :count)
              expect(response).to have_http_status :unauthorized
              expect(response.parsed_body['errors']).not_to be_nil
            end
          end
        end
      end
    end
  end
end
