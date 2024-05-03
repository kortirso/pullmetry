# frozen_string_literal: true

module Import
  module Savers
    class Reviews
      include Concerns::FindOrCreateEntity

      def call(pull_request:, data:)
        @pull_request = pull_request
        ActiveRecord::Base.transaction do
          destroy_old_reviews(data)
          last_approved = find_last_approved_review(data)
          data.each do |payload|
            next if payload[:external_id].in?(existing_reviews)
            next if payload[:state] == ::PullRequests::Review::ACCEPTED && last_approved.exclude?(payload[:external_id])

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

      def find_last_approved_review(data)
        data
          .select { |item| item[:state] == ::PullRequests::Review::ACCEPTED }
          .group_by { |item| item[:author][:external_id] }
          .transform_values { |item| item.max_by { |element| element[:review_created_at] } }
          .values
          .flatten
          .pluck(:external_id)
      end

      def existing_reviews
        @existing_reviews ||=
          @pull_request
            .pull_requests_reviews
            .pluck(:external_id)
      end

      def create_review(entity, payload)
        review = @pull_request.pull_requests_reviews.where(external_id: nil).find_or_initialize_by(entity_id: entity)
        review.update!(external_id: payload[:external_id], review_created_at: payload[:review_created_at])
      end
    end
  end
end
