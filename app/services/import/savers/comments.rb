# frozen_string_literal: true

module Import
  module Savers
    class Comments
      prepend ApplicationService
      include Concerns::FindOrCreateEntity

      def initialize
        @pr_entities = {}
      end

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

            pr_entity = @pr_entities[entity_id] || find_or_create_pr_entity(entity_id)
            create_comment(pr_entity, payload)
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
          .pull_requests_comments
          .where.not(external_id: data.pluck(:external_id))
          .destroy_all
      end

      def existing_comments
        @existing_comments ||=
          @pull_request
          .pull_requests_comments
          .pluck(:external_id)
      end

      # here we create pr entity with reviewer origin because author's pr entity always exists
      def find_or_create_pr_entity(entity)
        result =
          @pull_request
          .pull_requests_entities
          .create_with(origin: ::PullRequests::Entity::REVIEWER)
          .find_or_create_by!(entity_id: entity)

        @pr_entities[entity] = result
        result
      end

      def create_comment(pr_entity, payload)
        pr_entity
          .pull_requests_comments
          .create!(external_id: payload[:external_id], comment_created_at: payload[:comment_created_at])
      end
    end
  end
end
