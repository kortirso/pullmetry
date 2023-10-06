# frozen_string_literal: true

module Import
  module Representers
    module Gitlab
      class Comments
        include Deps[entity_representer: 'services.import.representers.gitlab.entity']

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload[:id].to_s,
              comment_created_at: payload[:created_at],
              author: entity_representer.call(data: payload[:author])
            }
          end
        end
      end
    end
  end
end
