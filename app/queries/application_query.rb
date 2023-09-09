# frozen_string_literal: true

class ApplicationQuery
  class << self
    def resolve(...) = new.resolve(...)
    alias call resolve
  end

  def initialize(relation:) = @relation = relation
  def resolve(...) = relation

  private

  attr_reader :relation
end
