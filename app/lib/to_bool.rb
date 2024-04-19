# frozen_string_literal: true

class ToBool
  def call(value)
    boolean.cast(value) || false
  end

  private

  def boolean
    @boolean ||= ActiveModel::Type::Boolean.new
  end
end
