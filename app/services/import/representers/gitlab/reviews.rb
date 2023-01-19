# frozen_string_literal: true

module Import
  module Representers
    module Gitlab
      class Reviews
        def initialize(entity_representer: Entity.new)
          @entity_representer = entity_representer
        end

        def call(data:)
          data['approved_by'].map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload.dig('user', 'id'),
              review_created_at: data[:updated_at],
              author: @entity_representer.call(data: payload[:user])
            }
          end
        end
      end
    end
  end
end
