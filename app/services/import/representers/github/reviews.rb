# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Reviews
        def initialize(entity_representer: Entity.new)
          @entity_representer = entity_representer
        end

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload[:id].to_s,
              review_created_at: payload[:submitted_at],
              author: @entity_representer.call(data: payload[:user])
            }
          end
        end
      end
    end
  end
end
