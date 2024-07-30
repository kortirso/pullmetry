# frozen_string_literal: true

class BaseCommand
  class_attribute :contract

  def self.use_contract(&block)
    self.contract = Class.new(BaseContract, &block).new
  end

  def call(input={})
    errors = do_validate(input)
    return { errors: errors } if errors.present?

    do_prepare(input)
      .then { |input| do_persist(input) }
  end

  private

  def do_validate(input)
    return if contract.nil?

    validate(input)
  end

  def do_prepare(input) = input
  def do_persist(input) = raise NotImplementedError

  def validate(input)
    contract
      .call(input)
      .errors(locale: I18n.locale, full: true).to_h
      .values.flatten.map(&:capitalize)
  end
end
