# frozen_string_literal: true

module Import
  module Savers
    class Comments
      prepend ApplicationService
      include Concerns::FindOrCreateEntity

      def call(pull_request:, data:)
        @pull_request = pull_request

        ActiveRecord::Base.transaction do
          destroy_old_comments(data)
          data.each do |payload|
            next if payload[:external_id].in?(existing_comments)

            entity = find_or_create_entity(payload.delete(:author))
            next if entity == author_entity

            pr_entity = find_or_create_pr_entity(entity)
            create_comment(pr_entity, payload)
          end
        end
      end

      private

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
        @pull_request
          .pull_requests_entities
          .create_with(origin: ::PullRequests::Entity::REVIEWER)
          .find_or_create_by!(entity_id: entity)
      end

      def create_comment(pr_entity, payload)
        pr_entity
          .pull_requests_comments
          .create_with(comment_created_at: payload[:comment_created_at])
          .find_or_create_by!(external_id: payload[:external_id])
      end
    end
  end
end
