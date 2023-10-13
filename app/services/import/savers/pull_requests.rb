# frozen_string_literal: true

module Import
  module Savers
    class PullRequests
      include Concerns::FindOrCreateEntity

      ALLOWED_ATTRIBUTES = %i[pull_number pull_created_at pull_closed_at pull_merged_at].freeze

      def initialize
        @author_entities = {}
      end

      def call(repository:, data:)
        @repository = repository
        ActiveRecord::Base.transaction do
          destroy_old_pull_requests(data)
          # proceed only open pull requests
          data.reject! { |payload| reject_pull_request?(payload) }
          # select uniq authors
          # find_create entities for all authors
          find_or_create_author_entities(data.pluck(:author, :reviewers))
          data.each do |payload|
            save_pull_request(payload, find_entity_by_id(payload.dig(:author, :external_id)))
            save_requested_reviewers(find_reviewers_entities(payload[:reviewers]))
          end
          update_repository(data) if data.any?
        end
      end

      private

      def find_entity_by_id(external_id)
        @author_entities[external_id]
      end

      def find_reviewers_entities(reviewers)
        reviewers.map { |reviewer| find_entity_by_id(reviewer[:external_id]) }
      end

      def destroy_old_pull_requests(data)
        @repository
          .pull_requests
          .where.not(pull_number: data.pluck(:pull_number))
          .destroy_all
      end

      def reject_pull_request?(payload)
        return true if payload[:pull_number].in?(existing_closed_pull_requests)
        return true if attribute_in_exclude_rules?(payload, :title)
        return true if attribute_in_exclude_rules?(payload, :description)
        return true if attribute_in_exclude_rules?(payload, :branch_name)
        return true if attribute_in_exclude_rules?(payload, :destination_branch_name)

        false
      end

      def attribute_in_exclude_rules?(payload, attribute)
        exclude_rules[attribute]&.any? { |rule| payload[attribute]&.include?(rule) }
      end

      def find_or_create_author_entities(authors)
        authors.flatten.each { |payload| @author_entities[payload[:external_id]] ||= find_or_create_entity(payload) }
      end

      def existing_closed_pull_requests
        @existing_closed_pull_requests ||=
          @repository
            .pull_requests
            .closed
            .pluck(:pull_number)
      end

      # { title: [], description: [], branch_name: [], destination_branch_name: ['master'] }
      def exclude_rules
        @exclude_rules ||= JSON.parse(@repository.configuration.pull_request_exclude_rules || '{}').symbolize_keys
      end

      def save_pull_request(payload, author_entity)
        @pull_request =
          @repository
          .pull_requests
          .find_or_initialize_by(pull_number: payload.delete(:pull_number))
        # if pull request tries to change state from draft to created, so it exists already
        # then pull_created_at must be set to current time
        # because pull_created_at value can contain long time ago value when PR was created as draft
        if !@pull_request.new_record? && @pull_request.draft? && payload[:pull_created_at].present?
          payload[:pull_created_at] = DateTime.now
        end

        @pull_request.update!(payload.slice(*ALLOWED_ATTRIBUTES).merge(entity_id: author_entity))
      end

      def save_requested_reviewers(reviewer_entities)
        existing_reviewer_entities = @pull_request.pull_requests_reviews.pluck(:entity_id)
        result = (reviewer_entities - existing_reviewer_entities).map do |entity|
          {
            entity_id: entity,
            pull_request_id: @pull_request.id,
            required: true
          }
        end
        ::PullRequests::Review.upsert_all(result) if result.any?
      end

      def update_repository(data)
        # commento: repositories.owner_avatar_url
        @repository.update!(owner_avatar_url: data.pluck(:owner_avatar_url).uniq.compact.first)
      end
    end
  end
end
