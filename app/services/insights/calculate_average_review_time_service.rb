# frozen_string_literal: true

module Insights
  class CalculateAverageReviewTimeService
    prepend ApplicationService

    SECONDS_IN_DAY = 86_400
    MINUTES_IN_HOUR = 60

    def call(insightable:)
      @insightable = insightable
      @result = {}
      insightable.pull_requests.includes(pull_requests_reviews: :pull_requests_entity).each do |pull_request|
        pull_request.pull_requests_reviews.each do |review|
          # TODO: add penalties for not reviewing
          # https://github.com/kortirso/pullmetry/issues/16
          entity_id = review.pull_requests_entity.entity_id
          update_result_with_total_review_time(entity_id, calculate_review_seconds(review, pull_request))
        end
      end
      update_result_with_average_time
    end

    private

    def calculate_review_seconds(review, pull_request)
      return review.review_created_at.to_i - pull_request.pull_created_at.to_i unless @insightable.with_work_time?

      seconds_between_times(
        convert_time(pull_request.pull_created_at).to_i,
        convert_time(review.review_created_at)
      )
    end

    # if time is less than beginning of work day - use beginning of work day
    # if time is more than ending of work day - use ending of work day
    def convert_time(value)
      value_minutes = (value.hour * MINUTES_IN_HOUR) + value.min

      if value_minutes < work_start_time_minutes
        value.change(hour: work_start_time.hour, min: work_start_time.min, sec: 0)
      elsif value_minutes > work_end_time_minutes
        value.change(hour: work_end_time.hour, min: work_end_time.min, sec: 0)
      else
        value
      end
    end

    def seconds_between_times(start_time, end_time)
      days = (end_time.end_of_day.to_i - start_time) / SECONDS_IN_DAY

      (end_time.to_i - start_time) - (days * not_working_night_seconds)
    end

    def update_result_with_total_review_time(entity_id, review_seconds)
      @result[entity_id] = @result.key?(entity_id) ? @result[entity_id].push(review_seconds) : [review_seconds]
    end

    def update_result_with_average_time
      @result.transform_values! { |value| value.sum / value.size }
    end

    def work_start_time_minutes
      @work_start_time_minutes ||= (work_start_time.hour * MINUTES_IN_HOUR) + work_start_time.min
    end

    def work_end_time_minutes
      @work_end_time_minutes ||= (work_end_time.hour * MINUTES_IN_HOUR) + work_end_time.min
    end

    # seconds between ending time previous day and starting time of new day in seconds
    def not_working_night_seconds
      @not_working_night_seconds ||= work_start_time.to_i - (work_end_time - 1.day).to_i
    end

    def work_start_time
      @work_start_time ||= @insightable.configuration.work_start_time
    end

    def work_end_time
      @work_end_time ||= @insightable.configuration.work_end_time
    end
  end
end
