# frozen_string_literal: true

module Excludes
  class GroupSerializer < ApplicationSerializer
    set_id :uuid

    attribute :excludes_rules do |object, params|
      params[:rules][object.uuid].presence || []
    end
  end
end
