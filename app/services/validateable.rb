# frozen_string_literal: true

module Validateable
  private

  def validate_with(validator, params={})
    errors = validator.call(params: params)
    fails!(errors) if errors.any?
  end
end
