# frozen_string_literal: true

describe Api::Frontend::Notifications::WebhooksController do
  let!(:user) { create :user }
  let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

  describe 'POST#create' do
    context 'for logged users' do
      let!(:another_user) { create :user }
      let!(:company) { create :company, user: user }
      let!(:notification) { create :notification, notifyable: company, source: 'custom' }

      context 'for unexisting notification' do
        let(:request) {
          post :create, params: {
            notification_id: 'unexisting', webhook: { url: '' }, auth_token: access_token
          }
        }

        it 'does not create webhook', :aggregate_failures do
          expect { request }.not_to change(Webhook, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for invalid notification' do
        let(:request) {
          post :create, params: {
            notification_id: notification.uuid, webhook: { url: '' }, auth_token: access_token
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
              notification_id: notification.uuid, webhook: { url: '' }, auth_token: access_token
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
              notification_id: notification.uuid, webhook: { url: '1123' }, auth_token: access_token
            }
          }

          before { notification.update!(source: 'slack') }

          it 'does not create webhook', :aggregate_failures do
            expect { request }.not_to change(Webhook, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Invalid Slack webhook url'
          end
        end

        context 'for invalid custom url format' do
          let(:request) {
            post :create, params: {
              notification_id: notification.uuid, webhook: { url: '1123' }, auth_token: access_token
            }
          }

          it 'does not create webhook', :aggregate_failures do
            expect { request }.not_to change(Webhook, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Invalid Webhook url'
          end
        end

        context 'for existing webhook with such source' do
          let(:request) {
            post :create, params: {
              notification_id: notification.uuid, webhook: {
                url: 'https://hooks.slack.com/services/url'
              }, auth_token: access_token
            }
          }

          before do
            notification.update!(source: 'slack')
            create :webhook, webhookable: notification, source: 'slack'
          end

          it 'does not create webhook', :aggregate_failures do
            expect { request }.not_to change(Webhook, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Webhook already exists'
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              notification_id: notification.uuid,
              webhook: { url: 'https://hooks.slack.com/services/url' },
              auth_token: access_token
            }
          }

          before { notification.update!(source: 'slack') }

          it 'creates webhook', :aggregate_failures do
            expect { request }.to change(Webhook.slack, :count).by(1)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end
        end

        context 'for valid custom params' do
          let(:request) {
            post :create, params: {
              notification_id: notification.uuid,
              webhook: { url: 'https://hooks.slack.com/services/url' },
              auth_token: access_token
            }
          }

          it 'creates webhook', :aggregate_failures do
            expect { request }.to change(Webhook.custom, :count).by(1)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end
        end
      end
    end
  end
end
