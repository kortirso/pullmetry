# frozen_string_literal: true

describe Webhooks::TelegramsController do
  describe 'POST#create' do
    before do
      allow(Pullmetry::Container.resolve('bot.telegram.client')).to receive(:call)
    end

    context 'when message is not present in payload', :aggregate_failures do
      it 'does not call bot' do
        post :create, params: {}

        expect(Pullmetry::Container.resolve('bot.telegram.client')).not_to have_received(:call)
        expect(response).to have_http_status :ok
      end
    end

    context 'when message present in payload', :aggregate_failures do
      it 'calls bot' do
        post :create, params: {
          message: { from: { first_name: 'First', last_name: 'Last' }, chat: { id: 'id' }, text: 'text' }
        }

        expect(Pullmetry::Container.resolve('bot.telegram.client')).to(
          have_received(:call).with(
            params: {
              from: { first_name: 'First', last_name: 'Last' },
              chat: { id: 'id' },
              text: 'text'
            }
          )
        )
        expect(response).to have_http_status :ok
      end
    end
  end
end
