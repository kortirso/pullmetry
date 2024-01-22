# frozen_string_literal: true

describe Webhooks::CryptocloudsController do
  describe 'POST#create' do
    let(:decode_result) { {} }

    before do
      allow(Pullmetry::Container.resolve('jwt_encoder')).to receive(:decode).and_return(decode_result)
    end

    context 'when status is not success' do
      let(:request) { post :create, params: { status: 'failed' } }

      it 'does not create subscription', :aggregate_failures do
        expect { request }.not_to change(Subscription, :count)
        expect(response).to have_http_status :ok
      end
    end

    context 'when status is success' do
      context 'when user is not found' do
        let(:request) { post :create, params: { status: 'success' } }

        it 'does not create subscription', :aggregate_failures do
          expect { request }.not_to change(Subscription, :count)
          expect(response).to have_http_status :not_found
        end
      end

      context 'when user is found' do
        let!(:user) { create :user }

        context 'when token is invalid' do
          let(:request) { post :create, params: { status: 'success', order_id: user.uuid } }

          it 'does not create subscription', :aggregate_failures do
            expect { request }.not_to change(Subscription, :count)
            expect(response).to have_http_status :ok
          end
        end

        context 'when token is valid' do
          let(:decode_result) { { 'id' => '123' } }

          context 'when invoice id is invalid' do
            let(:request) { post :create, params: { status: 'success', order_id: user.uuid, invoice_id: '321' } }

            it 'does not create subscription', :aggregate_failures do
              expect { request }.not_to change(Subscription, :count)
              expect(response).to have_http_status :ok
            end
          end

          context 'when invoice id is valid' do
            let(:request) { post :create, params: { status: 'success', order_id: user.uuid, invoice_id: '123' } }

            it 'does not create subscription', :aggregate_failures do
              expect { request }.to change(user.subscriptions, :count).by(1)
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end
  end
end
