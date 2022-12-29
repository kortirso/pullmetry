# frozen_string_literal: true

class ApplicationContract < Dry::Validation::Contract
  def self.call(...)
    new.call(...)
  end

  config.messages.backend = :i18n
end
