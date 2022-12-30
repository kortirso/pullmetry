# frozen_string_literal: true

module Import
  module Savers
    class PullRequests
      prepend ApplicationService
      include Concerns::FindOrCreateEntity

      def call(repository:, data:)
        @repository = repository

        ActiveRecord::Base.transaction do
          destroy_old_pull_requests(data)
          data.each do |payload|
            author_entity = find_or_create_entity(payload.delete(:author))
            reviewer_entities = payload.delete(:reviewers).map { |reviewer| find_or_create_entity(reviewer) }
            save_pull_request(payload)
            save_pull_requests_entities(author_entity, reviewer_entities)
          end
        end
      end

      private

      def destroy_old_pull_requests(data)
        @repository
          .pull_requests
          .where.not(pull_number: data.pluck(:pull_number))
          .destroy_all
      end

      def save_pull_request(payload)
        @pull_request = @repository.pull_requests.find_or_initialize_by(pull_number: payload.delete(:pull_number))
        @pull_request.update!(payload)
      end

      def save_pull_requests_entities(author_entity, reviewer_entities)
        ::PullRequests::Entity.find_or_create_by!(
          entity_id: author_entity,
          pull_request: @pull_request,
          origin: ::PullRequests::Entity::AUTHOR
        )
        # TODO: add destroying removed reviewers
        reviewer_entities.each do |entity|
          ::PullRequests::Entity.find_or_create_by!(
            entity_id: entity,
            pull_request: @pull_request,
            origin: ::PullRequests::Entity::REVIEWER
          )
        end
      end
    end
  end
end
