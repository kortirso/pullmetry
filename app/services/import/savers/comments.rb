# frozen_string_literal: true

module Import
  module Savers
    class Comments
      include Concerns::FindOrCreateEntity

      def call(pull_request:, data:)
        @pull_request = pull_request
        ActiveRecord::Base.transaction do
          destroy_old_comments(data)
          # proceed only new comments
          data.reject! { |payload| payload[:external_id].in?(existing_comments) }
          # select uniq authors
          # find_create entities for all authors
          find_or_create_author_entities(data.pluck(:author).uniq)

          data.each do |payload|
            # skip PR author comments
            entity_id = @author_entities[payload.dig(:author, :external_id)]
            next unless entity_id

            create_comment(entity_id, payload)
          end
        end
      end

      private

      def find_or_create_author_entities(authors)
        @author_entities = {}
        authors.each do |payload|
          entity_id = find_or_create_entity(payload)
          next if entity_id == author_entity

          @author_entities[payload[:external_id]] = entity_id
        end
      end

      def destroy_old_comments(data)
        @pull_request
          .comments
          .where.not(external_id: data.pluck(:external_id))
          .destroy_all
      end

      def existing_comments
        @existing_comments ||=
          @pull_request
            .comments
            .pluck(:external_id)
      end

      def create_comment(entity_id, payload)
        # commento: pull_requests_comments.external_id, pull_requests_comments.comment_created_at
        # commento: pull_requests_comments.parsed_body
        @pull_request.comments.create!(
          payload.slice(:external_id, :comment_created_at, :parsed_body).merge(entity_id: entity_id)
        )
      end
    end
  end
end
