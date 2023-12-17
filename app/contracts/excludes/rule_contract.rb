# frozen_string_literal: true

module Excludes
  class RuleContract < ApplicationContract
    config.messages.namespace = :excludes_rule

    params do
      required(:target).filled(:string)
      required(:condition).filled(:string)
      required(:value).filled(:string)
    end

    rule(:target) do
      if Excludes::Rule.targets.keys.exclude?(values[:target])
        key(:target).failure(:unexisting)
      end
    end

    rule(:condition) do
      if Excludes::Rule.conditions.keys.exclude?(values[:condition])
        key(:condition).failure(:unexisting)
      end
    end
  end
end
