# frozen_string_literal: true

class ApplicationValidator
  def self.call(...)
    new.call(...)
  end

  def call(params:)
    validation = @contract.call(params.to_h)
    validation.errors(locale: I18n.locale, full: true).to_h.values.flatten.map(&:capitalize)
  end
end
