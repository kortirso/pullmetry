# frozen_string_literal: true

class WebhookValidator < ApplicationValidator
  include Deps[contract: 'contracts.webhook']
end
