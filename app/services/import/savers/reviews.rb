# frozen_string_literal: true

module Import
  module Savers
    class Reviews
      prepend ApplicationService
      include Concerns::FindOrCreateEntity

      def call(pull_request:, data:)
        @pull_request = pull_request
        ActiveRecord::Base.transaction do
          destroy_old_reviews(data)
          data.each do |payload|
            next if payload[:external_id].in?(existing_reviews)

            entity = find_or_create_entity(payload.delete(:author))
            next if entity == author_entity

            pr_entity = find_or_create_pr_entity(entity)
            create_review(pr_entity, payload)
          end
        end
      end

      private

      def destroy_old_reviews(data)
        @pull_request
          .pull_requests_reviews
          .where.not(external_id: data.pluck(:external_id))
          .destroy_all
      end

      def existing_reviews
        @existing_reviews ||=
          @pull_request
          .pull_requests_reviews
          .pluck(:external_id)
      end

      def find_or_create_pr_entity(entity)
        @pull_request
          .pull_requests_entities
          .find_or_create_by!(entity_id: entity)
      end

      def create_review(pr_entity, payload)
        pr_entity.pull_requests_reviews.create!(payload.slice(:external_id, :review_created_at))
      end
    end
  end
end
