# frozen_string_literal: true

describe Api::Frontend::NotificationsController do
  let!(:user) { create :user }
  let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }
  let!(:company) { create :company, user: user }
  let!(:webhook) { create :webhook, company: company }
  let!(:another_user) { create :user }

  describe 'POST#create' do
    context 'for logged users' do
      context 'for invalid company' do
        let(:request) {
          post :create, params: {
            company_id: company.uuid,
            webhook_id: 'unexisting',
            notification: { notification_type: '' },
            auth_token: access_token
          }
        }

        before { company.update!(user: another_user) }

        it 'does not create notification', :aggregate_failures do
          expect { request }.not_to change(Notification, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for valid company' do
        context 'for unexisting webhook' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              webhook_id: 'unexisting',
              notification: { notification_type: '' },
              auth_token: access_token
            }
          }

          it 'does not create notification', :aggregate_failures do
            expect { request }.not_to change(Notification, :count)
            expect(response).to have_http_status :not_found
            expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
          end
        end

        context 'for invalid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              webhook_id: webhook.uuid,
              notification: { notification_type: '' },
              auth_token: access_token
            }
          }

          it 'does not create notification', :aggregate_failures do
            expect { request }.not_to change(Notification, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Notification type must be filled'
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              webhook_id: webhook.uuid,
              notification: { notification_type: 'insights_data' },
              auth_token: access_token
            }
          }

          it 'creates notification', :aggregate_failures do
            expect { request }.to change(company.notifications, :count).by(1)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end

          context 'for existing similar notification' do
            before do
              create :notification, notifyable: company, webhook: webhook, notification_type: 'insights_data'
            end

            it 'does not create notification', :aggregate_failures do
              expect { request }.not_to change(Notification, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body.dig('errors', 0)).to eq 'Notification already exists'
            end
          end
        end
      end
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      let!(:notification) { create :notification, notifyable: company }
      let(:request) { delete :destroy, params: { id: notification.uuid, auth_token: access_token } }

      context 'for not existing notification' do
        let(:request) { delete :destroy, params: { id: 'unexisting', auth_token: access_token } }

        it 'does not destroy notification', :aggregate_failures do
          expect { request }.not_to change(Notification, :count)
          expect(response).to have_http_status :not_found
        end
      end

      context 'for not user company notification' do
        before { company.update!(user: another_user) }

        it 'does not destroy notification', :aggregate_failures do
          expect { request }.not_to change(Notification, :count)
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'for user company notification' do
        it 'destroys notification', :aggregate_failures do
          expect { request }.to change(Notification, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
