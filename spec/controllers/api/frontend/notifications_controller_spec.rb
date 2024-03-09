# frozen_string_literal: true

describe Api::Frontend::NotificationsController do
  let!(:user) { create :user }
  let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }
  let!(:company) { create :company, user: user }
  let!(:another_user) { create :user }

  describe 'POST#create' do
    context 'for logged users' do
      context 'for invalid company' do
        let(:request) {
          post :create, params: {
            company_id: company.uuid,
            notification: { source: 'custom', notification_type: '' },
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
        context 'for invalid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              notification: { source: 'custom', notification_type: '' },
              auth_token: access_token
            }
          }

          it 'does not create notification', :aggregate_failures do
            expect { request }.not_to change(Notification, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Notification type must be filled'
          end
        end

        context 'for existing notification' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              notification: { source: 'slack', notification_type: 'insights_data' },
              auth_token: access_token
            }
          }

          before { create :notification, notifyable: company, source: 'slack', notification_type: 'insights_data' }

          it 'does not create notification', :aggregate_failures do
            expect { request }.not_to change(Notification, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              company_id: company.uuid,
              notification: { source: 'slack', notification_type: 'insights_data' },
              auth_token: access_token
            }
          }

          it 'creates notification', :aggregate_failures do
            expect { request }.to change(company.notifications.slack, :count).by(1)
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
      let!(:notification) do
        create :notification, source: Webhook::SLACK, notification_type: 'insights_data', notifyable: company
      end
      let(:request) do
        delete :destroy, params: {
          company_id: company.uuid,
          notification: { source: 'slack', notification_type: 'insights_data' },
          auth_token: access_token
        }
      end

      context 'for not user company notification' do
        before { company.update!(user: another_user) }

        it 'does not disable notification', :aggregate_failures do
          request

          expect(notification.reload.enabled).to be_truthy
          expect(response).to have_http_status :not_found
        end
      end

      context 'for user company notification' do
        before { notification.notifyable.update!(user: user) }

        it 'disables notification', :aggregate_failures do
          request

          expect(notification.reload.enabled).to be_falsy
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { company_id: 'unexisting' }
    end
  end
end
