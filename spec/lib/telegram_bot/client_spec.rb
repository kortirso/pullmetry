# frozen_string_literal: true

describe TelegramBot::Client, type: :service do
  subject(:service_call) { instance.call(params: { from: from, chat: chat, text: text }) }

  let!(:instance) { described_class.new }
  let(:from) { { first_name: 'First', last_name: 'Last' } }
  let(:chat) { { id: 'id' } }
  let(:text) { 'text' }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_return('secret')
    allow(Pullmetry::Container.resolve('api.telegram.client')).to receive(:send_message)
  end

  context 'for /help' do
    let(:text) { '/help' }

    it 'sends message' do
      service_call

      expect(Pullmetry::Container.resolve('api.telegram.client')).to(
        have_received(:send_message).with(
          bot_secret: 'secret',
          chat_id: 'id',
          text: "Available commands are:\n/start\n/help\n/get_chat_id"
        )
      )
    end
  end

  context 'for /start' do
    let(:text) { '/start' }

    it 'sends message' do
      service_call

      expect(Pullmetry::Container.resolve('api.telegram.client')).to(
        have_received(:send_message).with(
          bot_secret: 'secret',
          chat_id: 'id',
          text: "Hello, First Last\nTo see list of commands type /help"
        )
      )
    end
  end

  context 'for /get_chat_id' do
    let(:text) { '/get_chat_id' }

    it 'sends message' do
      service_call

      expect(Pullmetry::Container.resolve('api.telegram.client')).to(
        have_received(:send_message).with(
          bot_secret: 'secret',
          chat_id: 'id',
          text: 'Chat id is id'
        )
      )
    end
  end

  context 'for unknown_message' do
    it 'sends message' do
      service_call

      expect(Pullmetry::Container.resolve('api.telegram.client')).to(
        have_received(:send_message).with(
          bot_secret: 'secret',
          chat_id: 'id',
          text: "I don't know what to say, sorry :("
        )
      )
    end
  end
end
