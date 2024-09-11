# frozen_string_literal: true

require 'dry/logic/predicates'

module Dry
  module Logic
    module Predicates
      # required(:instance).value(type_included_in?: [Class1, Class2])
      predicate :type_included_in? do |constants, input|
        Array(constants).any? { |constant| input.is_a?(constant) }
      end
    end
  end
end
