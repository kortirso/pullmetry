# frozen_string_literal: true

module Import
  module Representers
    module Gitlab
      class Comments
        include Deps[entity_representer: 'services.import.representers.gitlab.entity']
        include Import::Concerns::CommentParseable

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              external_id: payload[:id].to_s,
              comment_created_at: payload[:created_at],
              author: entity_representer.call(data: payload[:author]),
              parsed_body: parse_comment_body(payload[:body]&.lines&.first)
            }
          end
        end
      end
    end
  end
end
