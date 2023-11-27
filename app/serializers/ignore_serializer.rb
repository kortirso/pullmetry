# frozen_string_literal: true

class IgnoreSerializer < ApplicationSerializer
  set_id :uuid

  attributes :entity_value
end
