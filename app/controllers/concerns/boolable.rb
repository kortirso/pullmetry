# frozen_string_literal: true

module Boolable
  extend ActiveSupport::Concern

  private

  def to_bool(value)
    ActiveModel::Type::Boolean.new.cast(value) || false
  end
end
