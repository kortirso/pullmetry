# frozen_string_literal: true

describe Api::Frontend::WebhooksController do
  let!(:user) { create :user }
  let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

  describe 'POST#create' do
    context 'for logged users' do
      let!(:another_user) { create :user }
      let!(:company) { create :company, user: user }

      context 'for invalid company' do
        let(:request) {
          post :create, params: {
            company_id: company.uuid, webhook: { source: 'custom', url: '' }, auth_token: access_token
          }
        }

        before { company.update!(user: another_user) }

        it 'does not create webhook', :aggregate_failures do
          expect { request }.not_to change(Webhook, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for valid company' do
        context 'for invalid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid, webhook: { source: 'custom', url: '' }, auth_token: access_token
            }
          }

          it 'does not create webhook', :aggregate_failures do
            expect { request }.not_to change(Webhook, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Url must be filled'
          end
        end

        context 'for invalid url format' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid, webhook: { source: 'slack', url: '1123' }, auth_token: access_token
            }
          }

          it 'does not create webhook', :aggregate_failures do
            expect { request }.not_to change(Webhook, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Invalid Slack webhook url'
          end
        end

        context 'for existing webhook with such source' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid, webhook: { source: 'slack', url: '1123' }, auth_token: access_token
            }
          }

          before { create :webhook, insightable: company, source: 'slack' }

          it 'does not create webhook', :aggregate_failures do
            expect { request }.not_to change(Webhook, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'There is already webhook with such source'
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              webhook: { source: 'slack', url: 'https://hooks.slack.com/services/url' },
              auth_token: access_token
            }
          }

          it 'creates webhook', :aggregate_failures do
            expect { request }.to change(company.webhooks, :count).by(1)
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
      let!(:webhook) { create :webhook }
      let(:request) { delete :destroy, params: { id: webhook.uuid, auth_token: access_token } }

      context 'for not user webhook' do
        it 'does not destroy webhook', :aggregate_failures do
          expect { request }.not_to change(Webhook, :count)
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'for user webhook' do
        before { webhook.insightable.update!(user: user) }

        it 'destroys webhook', :aggregate_failures do
          expect { request }.to change(Webhook, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end