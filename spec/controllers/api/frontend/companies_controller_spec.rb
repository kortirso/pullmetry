# frozen_string_literal: true

describe Api::Frontend::CompaniesController do
  describe 'POST#create' do
    context 'for logged users' do
      let!(:user) { create :user }
      let!(:another_user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for invalid params' do
        let(:request) { post :create, params: { company: { title: '' }, auth_token: access_token } }

        it 'does not create company', :aggregate_failures do
          expect { request }.not_to change(Company, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq 'Title must be filled'
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { company: { title: 'Title' }, auth_token: access_token } }

        it 'creates company', :aggregate_failures do
          expect { request }.to change(user.companies, :count).by(1)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).to be_nil
        end

        context 'for external account' do
          let(:request) {
            post :create, params: {
              company: { title: 'Title', user_uuid: another_user.uuid }, auth_token: access_token
            }
          }

          context 'without write access' do
            it 'does not create company', :aggregate_failures do
              expect { request }.not_to change(Company, :count)
              expect(response).to have_http_status :not_found
              expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
            end
          end

          context 'with read access' do
            before { create :invite, inviteable: another_user, receiver: user, code: nil, access: Invite::READ }

            it 'does not create company', :aggregate_failures do
              expect { request }.not_to change(Company, :count)
              expect(response).to have_http_status :not_found
              expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
            end
          end

          context 'with write access' do
            before { create :invite, inviteable: another_user, receiver: user, code: nil, access: Invite::WRITE }

            it 'creates company', :aggregate_failures do
              expect { request }.to change(Company, :count).by(1)
              expect(Company.last.user_id).to eq another_user.id
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end
  end
end
