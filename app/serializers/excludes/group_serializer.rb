# frozen_string_literal: true

module Excludes
  class GroupSerializer < ApplicationSerializer
    attributes :uuid, :excludes_rules

    def excludes_rules
      context[:rules][object.uuid].presence || []
    end
  end
end
