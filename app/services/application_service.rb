# frozen_string_literal: true

module ApplicationService
  def self.prepended(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def call(...)
      new.call(...)
    end
  end

  attr_reader :errors, :result

  def initialize(...)
    super(...)
    @errors = []
  end

  def call(...)
    super(...)
    self
  end

  def success?
    !failure?
  end

  def failure?
    @errors.any?
  end

  private

  def fails!(messages)
    @errors = messages
  end

  def fail!(message)
    @errors.push(message)
  end
end
