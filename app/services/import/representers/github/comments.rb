# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Comments
        include Deps[entity_representer: 'services.import.representers.github.entity']
        include Import::Concerns::CommentParseable

        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            # payload [:reactions] contains hash
            # "+1"=>0, "-1"=>0, "laugh"=>0, "hooray"=>0, "confused"=>0, "heart"=>0, "rocket"=>0, "eyes"=>0
            {
              external_id: payload[:id].to_s,
              comment_created_at: payload[:created_at],
              author: entity_representer.call(data: payload[:user]),
              parsed_body: parse_comment_body(payload[:body]&.lines&.first)
            }
          end
        end
      end
    end
  end
end
