# frozen_string_literal: true

class Entity
  class IgnoreSerializer < ApplicationSerializer
    attributes :uuid, :entity_value
  end
end
