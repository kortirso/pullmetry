# frozen_string_literal: true

module Parameterable
  extend ActiveSupport::Concern

  InvalidInputParamsError = Class.new(StandardError)

  included do
    rescue_from InvalidInputParamsError, with: :invalid_params
  end

  private

  def schema_params(params:, schema:, required: nil)
    params = params.require(required) if required
    result = schema.call(params.to_unsafe_h)
    raise Parameterable::InvalidInputParamsError.new if result.errors.any?

    result.output
  end

  def invalid_params
    render json: { errors: ['Invalid input params'] }, status: :unprocessable_entity
  end
end
