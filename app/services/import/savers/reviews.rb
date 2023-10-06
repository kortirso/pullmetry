# frozen_string_literal: true

module Import
  module Savers
    class Reviews
      include Concerns::FindOrCreateEntity

      def call(pull_request:, data:)
        @pull_request = pull_request
        ActiveRecord::Base.transaction do
          destroy_old_reviews(data)
          data.each do |payload|
            next if payload[:external_id].in?(existing_reviews)

            entity = find_or_create_entity(payload.delete(:author))
            next if entity == author_entity

            create_review(entity, payload)
          end
        end
      end

      private

      def destroy_old_reviews(data)
        @pull_request
          .pull_requests_reviews
          .where.not(external_id: nil)
          .where.not(external_id: data.pluck(:external_id))
          .destroy_all
      end

      def existing_reviews
        @existing_reviews ||=
          @pull_request
            .pull_requests_reviews
            .pluck(:external_id)
      end

      def create_review(entity, payload)
        @pull_request
          .pull_requests_reviews
          .where(external_id: nil)
          .find_or_create_by(entity_id: entity) do |review|
            review.external_id = payload[:external_id]
            review.review_created_at = payload[:review_created_at]
          end
      end
    end
  end
end
