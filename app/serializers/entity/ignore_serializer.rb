# frozen_string_literal: true

class Entity
  class IgnoreSerializer < ApplicationSerializer
    attributes :id, :entity_value
  end
end
