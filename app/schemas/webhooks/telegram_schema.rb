# frozen_string_literal: true

Webhooks::TelegramSchema = Dry::Schema.Params do
  required(:message).hash do
    required(:from).hash do
      required(:first_name).filled(:string)
      required(:last_name).filled(:string)
    end
    required(:chat).hash do
      required(:id).filled(:string)
    end
    required(:text).filled(:string)
  end
end
