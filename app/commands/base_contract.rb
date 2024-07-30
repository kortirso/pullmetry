# frozen_string_literal: true

class BaseContract < Dry::Validation::Contract
  config.messages.backend = :i18n
  config.messages.top_namespace = 'dry_schema'
end
