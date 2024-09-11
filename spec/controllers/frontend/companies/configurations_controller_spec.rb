# frozen_string_literal: true

describe Frontend::Companies::ConfigurationsController do
  let!(:user) { create :user }
  let!(:users_session) { create :users_session, user: user }
  let!(:company) { create :company, configuration: { average_type: 'arithmetic_mean' } }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result] }

  describe 'PATCH#update' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      context 'for not existing company' do
        it 'returns not found response' do
          do_request(access_token)

          expect(response).to have_http_status :not_found
        end
      end

      context 'for not existing user company' do
        it 'returns forbidden error' do
          patch :update, params: {
            company_id: company.uuid, configuration: { average_type: 'median' }, pullmetry_access_token: access_token
          }

          expect(response).to have_http_status :forbidden
        end
      end

      context 'for existing user company' do
        before { company.update!(user: user) }

        context 'for invalid params' do
          it 'does not update configuration and redirects', :aggregate_failures do
            patch :update, params: {
              company_id: company.uuid, configuration: { average_type: '123' }, pullmetry_access_token: access_token
            }

            configuration = company.reload.configuration

            expect(configuration.average_type).to eq 'arithmetic_mean'
            expect(response).to have_http_status :ok
          end
        end

        context 'for valid params' do
          it 'updates regular configuration and redirects', :aggregate_failures do
            patch :update, params: {
              company_id: company.uuid, configuration: { average_type: 'median' }, pullmetry_access_token: access_token
            }

            configuration = company.reload.configuration

            expect(configuration.average_type).to eq 'median'
            expect(response).to have_http_status :ok
          end
        end
      end
    end

    def do_request(access_token=nil)
      patch :update, params: {
        company_id: 'unexisting', configuration: { average_type: 'median' }, pullmetry_access_token: access_token
      }
    end
  end
end
