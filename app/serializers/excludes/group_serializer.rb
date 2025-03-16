# frozen_string_literal: true

module Excludes
  class GroupSerializer < ApplicationSerializer
    attributes :id, :excludes_rules

    def excludes_rules
      context[:rules][object.id].presence || []
    end
  end
end
