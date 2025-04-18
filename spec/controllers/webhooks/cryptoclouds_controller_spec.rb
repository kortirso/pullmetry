# frozen_string_literal: true

describe Webhooks::CryptocloudsController do
  describe 'POST#create' do
    let(:monitoring) { Pullmetry::Container.resolve('monitoring.client') }

    before { allow(monitoring).to receive(:notify) }

    context 'when status is not success' do
      let(:request) { post :create, params: { status: 'failed' } }

      it 'does not create subscription', :aggregate_failures do
        expect { request }.not_to change(User::Subscription, :count)
        expect(monitoring).to have_received(:notify)
        expect(response).to have_http_status :ok
      end
    end

    context 'when status is success' do
      context 'when user is not found' do
        let(:request) { post :create, params: { status: 'success' } }

        it 'does not create subscription', :aggregate_failures do
          expect { request }.not_to change(User::Subscription, :count)
          expect(monitoring).to have_received(:notify)
          expect(response).to have_http_status :not_found
        end
      end

      context 'when user is found' do
        let!(:user) { create :user }
        let(:order_id) { JwtEncoder.new.encode(payload: { uuid: user.id, days_period: 30 }) }

        context 'when order id is invalid' do
          let(:request) { post :create, params: { status: 'success', order_id: '123' } }

          it 'does not create subscription', :aggregate_failures do
            expect { request }.not_to change(User::Subscription, :count)
            expect(monitoring).to have_received(:notify)
            expect(response).to have_http_status :not_found
          end
        end

        context 'when token is invalid' do
          let(:request) { post :create, params: { status: 'success', order_id: order_id } }

          it 'does not create subscription', :aggregate_failures do
            expect { request }.not_to change(User::Subscription, :count)
            expect(monitoring).to have_received(:notify)
            expect(response).to have_http_status :ok
          end
        end

        context 'when token is valid' do
          let(:invoice_token) {
            JwtEncoder.new.encode(payload: { id: '123' }, secret: Rails.application.credentials.secret_cryptoclouds)
          }

          context 'when invoice id is invalid' do
            let(:request) {
              post :create, params: { status: 'success', order_id: order_id, invoice_id: '321', token: invoice_token }
            }

            it 'does not create subscription', :aggregate_failures do
              expect { request }.not_to change(User::Subscription, :count)
              expect(monitoring).to have_received(:notify)
              expect(response).to have_http_status :ok
            end
          end

          context 'when invoice id is valid' do
            let(:request) {
              post :create, params: { status: 'success', order_id: order_id, invoice_id: '123', token: invoice_token }
            }

            before do
              allow(Pullmetry::Container.resolve('jwt_encoder')).to(
                receive(:decode).with(token: order_id).and_return({ 'uuid' => user.id, 'days_period' => 30 })
              )

              allow(Pullmetry::Container.resolve('jwt_encoder')).to(
                receive(:decode).with(token: invoice_token, secret: anything).and_return({ 'id' => '123' })
              )
            end

            it 'does not create subscription', :aggregate_failures do
              expect { request }.to change(user.subscriptions, :count).by(1)
              expect(monitoring).to have_received(:notify)
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end
  end
end
